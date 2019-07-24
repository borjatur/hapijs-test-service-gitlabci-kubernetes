FROM node:8.16.0-alpine
# Create a group and user
RUN addgroup -S nodejs && adduser -S nodejs -G nodejs
WORKDIR /home/nodejs/app
RUN chown -R nodejs:nodejs /home/nodejs/app
USER nodejs
COPY package*.json ./
RUN npm install
COPY . .
CMD [ "npm", "start" ]