# Dockerfile

# Use node version 18.13.0
FROM node:18.16.0 AS dependencies

LABEL maintainer="Bobby Li <bli120@myseneca.ca>"
LABEL description="Fragments node.js microservice"

# We default to use port 1234 in our service
ENV PORT=1234

# Reduce npm spam when installing within Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#loglevel
ENV NPM_CONFIG_LOGLEVEL=warn

# Disable colour when run inside Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#color
ENV NPM_CONFIG_COLOR=false

# Use /app as our working directory
WORKDIR /app

# Option 1: explicit path - Copy the package.json and package-lock.json
# files into /app. NOTE: the trailing `/` on `/app/`, which tells Docker
# that `app` is a directory and not a file.
COPY package*.json /app/

# Option 2: relative path - Copy the package.json and package-lock.json
# files into the working dir (/app).  NOTE: this requires that we have
# already set our WORKDIR in a previous step.
COPY package*.json ./

# Option 3: explicit filenames - Copy the package.json and package-lock.json
# files into the working dir (/app), using full paths and multiple source
# files.  All of the files will be copied into the working dir `./app`
COPY package.json package-lock.json ./

# # Install node dependencies defined in package-lock.json
# RUN npm install
# Enforce only production dependencies are installed
RUN npm ci
# RUN npm install
# RUN npm ci --only=production

##############################################################

FROM node:18.16.0 AS production

# Use /app as our working directory
WORKDIR /app

COPY --from=dependencies /app /app

# Copy src to /app/src/
COPY ./src ./src

# Start the container by running our server
CMD npx parcel

# We run our service on port 1234
EXPOSE 1234

