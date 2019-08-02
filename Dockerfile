FROM node:8.16.0-alpine
RUN apk add --update make
# Create a group and user
RUN addgroup -S nodejs && adduser -S nodejs -G nodejs
WORKDIR /home/nodejs/app
RUN chown -R nodejs:nodejs /home/nodejs/app
USER nodejs
COPY package*.json ./
RUN npm ci --production
COPY . .
CMD [ "npm", "start" ]