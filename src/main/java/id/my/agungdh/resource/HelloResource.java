package id.my.agungdh.resource;

import io.quarkus.qute.Location;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import io.quarkus.qute.TemplateInstance;
import io.quarkus.qute.Template;

@Path("hello")
public class HelloResource {

    @Inject
    @Location("layouts/default.html")
    Template hello;

    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get() {
        return hello.instance();
    }
}