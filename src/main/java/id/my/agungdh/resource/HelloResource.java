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
    Template hello;

    @GET
    @Produces(MediaType.TEXT_HTML)
    public TemplateInstance get(@QueryParam("name") String name) {
        return hello.data("name", name);
    }

    @GET()
    @Path("/dududuw")
    @Produces(MediaType.TEXT_HTML)
    @Location("/hellos-sddd.html")
    public TemplateInstance getDuduw(@QueryParam("name") String name) {
        return hello.data("name", name);
    }
}