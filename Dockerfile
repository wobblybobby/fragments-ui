# Build and serve fragments-ui with nginx

# Start with nginx on Debian
FROM nginx:stable

# Pick a version: 19, 18, 17, 16, 14, 12, lts, current, see:
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
ARG NODE_VERSION=18

# .env values
ARG API_URL=http://ec2co-ecsel-ypex6gwy0eyf-218612650.us-east-1.elb.amazonaws.com:8080
ARG AWS_COGNITO_POOL_ID=us-east-1_kie2BCnSi
ARG AWS_COGNITO_CLIENT_ID=t6eargfj9khmvnip6ut16fdkn
ARG AWS_COGNITO_HOSTED_UI_DOMAIN=bli-fragments.auth.us-east-1.amazoncognito.com
ARG OAUTH_SIGN_IN_REDIRECT_URL=http://localhost:80
ARG OAUTH_SIGN_OUT_REDIRECT_URL=http://localhost:80

# Install node.js and a build toolchain via apt-get, cleaing up when done.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
# https://explainshell.com/explain?cmd=curl+-fsSL+https%3A%2F%2Fdeb.nodesource.com%2Fsetup_%24%7BNODE_VERSION%7D.x+%7C+bash+-
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Reduce npm spam when installing within Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#loglevel
ENV NPM_CONFIG_LOGLEVEL=warn

# Disable colour when run inside Docker
# https://docs.npmjs.com/cli/v8/using-npm/config#color
ENV NPM_CONFIG_COLOR=false

# Use /usr/local/src/fragments-ui as our working directory
WORKDIR /usr/local/src/fragments-ui

# Copy all of our source in
COPY . .

# Install node dependencies defined in package.json and package-lock.json
RUN npm ci

# Run the parcel build in order to create ./dist, then
# copy all of the contents of dist/ to the location where
# nginx expects to find our HTML web content.  See
# https://explainshell.com/explain?cmd=cp+-a+.%2Fdist%2F.+%2Fusr%2Fshare%2Fnginx%2Fhtml%2F
RUN npm run build && \
    cp -a ./dist/. /usr/share/nginx/html/

# nginx will be running on port 80
EXPOSE 80