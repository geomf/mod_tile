#include <mapnik/version.hpp>
#include <mapnik/map.hpp>
#include <mapnik/layer.hpp>
#include <mapnik/params.hpp>
#include <mapnik/datasource.hpp>
#include <mapnik/datasource_cache.hpp>

#include <syslog.h>
#include <stdio.h>

#include <boost/optional.hpp>

#include "parameterize_style.hpp"

static bool parameterize_map_user(mapnik::Map &m, char * parameter) {
    unsigned int i;
    char name_replace[256];

    name_replace[0] = 0;
    syslog(LOG_DEBUG, "Modifying map to user parameter: %s", parameter);
    char * username = strdup(parameter);

    int user_id,digits;
    if (sscanf(username, "%u%n", &user_id, &digits) != 1 || username[digits] != 0) return false; //Wrong param
    sprintf(name_replace,"INNER JOIN feeders ON feeder_id=feeders.id WHERE feeders.user_id=%d AND",user_id);
    free(username);

    for (i = 0; i < m.layer_count(); i++) {
#if MAPNIK_VERSION >= 300000
        mapnik::layer& l = m.get_layer(i);
#else
        mapnik::layer& l = m.getLayer(i);
#endif
        mapnik::parameters params = l.datasource()->params();
        if (params.find("table") != params.end()) {
            boost::optional<std::string> table = params.get<std::string>("table");
            if (table && table->find("WHERE") != std::string::npos) {
                std::string str = *table;
                size_t pos = str.find("WHERE");
                str.replace(pos,5,name_replace);
                params["table"] = str;
#if MAPNIK_VERSION >= 200200
                l.set_datasource(mapnik::datasource_cache::instance().create(params));
#else
                l.set_datasource(mapnik::datasource_cache::instance()->create(params));
#endif
            } 
        }

    }
    return true;
}

parameterize_function_ptr init_parameterization_function(char * function_name) {
    syslog(LOG_INFO, "Loading parameterization function for %s", function_name);
    if (strcmp(function_name, "") == 0) {
        return NULL;
    //} else if (strcmp(function_name, "language") == 0) {
    //    return parameterize_map_language;
    } else if (strcmp(function_name, "user") == 0) {
        return parameterize_map_user;
    } else {
        syslog(LOG_INFO, "WARNING: unknown parameterization function for %s", function_name);
    }
    return NULL;
}
