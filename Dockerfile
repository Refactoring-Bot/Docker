#################################################################################################
# Java Builder
#################################################################################################
FROM maven:3-jdk-8 as javaBuilder
WORKDIR /app

# Clone the java repo
RUN git clone https://github.com/Refactoring-Bot/Refactoring-Bot.git
# Rename the example config
RUN mv /app/Refactoring-Bot/src/main/resources/application_example.yml /app/Refactoring-Bot/src/main/resources/application.yml
# Navigate into the directory and use Maven to build the JAR file
RUN cd Refactoring-Bot && mvn install -Dmaven.test.skip=true



#################################################################################################
# Node Builder
#################################################################################################
FROM node:10 as nodeBuilder
WORKDIR /app

# Clone the web UI repo
RUN git clone https://github.com/Refactoring-Bot/Refactoring-Bot-UI.git
# Navigate into the directory and use npm to build the app
RUN cd Refactoring-Bot-UI && npm i --no-progress && npm run build



#################################################################################################
# Final Image
#################################################################################################
FROM openjdk:8-jre-slim-stretch
WORKDIR /app

# Update repositories
RUN apt-get update

# Install nginx
RUN apt-get install -y nginx
RUN rm -rf /var/www/html/*

# Copy JAR file to image workdir
COPY --from=javaBuilder /app/Refactoring-Bot/target/RefactoringBot-0.0.1-SNAPSHOT.jar /app/RefactoringBot.jar

# Copy web app to nginx html dir
COPY --from=nodeBuilder /app/Refactoring-Bot-UI/target/ /var/www/html/

# Start command with web server and JAR file
CMD nginx && java -jar /app/RefactoringBot.jar