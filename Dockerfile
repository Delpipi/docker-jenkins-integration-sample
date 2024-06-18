FROM openjdk:21-oracle
EXPOSE 8083
VOLUME /tmp
COPY target/*.jar  app.jar
ENTRYPOINT ["java","-jar", "app.jar"]