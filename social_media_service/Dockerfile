FROM ballerina/ballerina:latest

# Copy the Ballerina source file to the container
COPY social_media_service.bal /home/ballerina/
COPY Config.toml /home/ballerina/

# Expose the port on which the Ballerina service will run
EXPOSE 9091

# Run the Ballerina service
CMD bal run social_media_service.bal
