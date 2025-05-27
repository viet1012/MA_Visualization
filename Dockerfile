# Dùng nginx base image
FROM nginx:alpine

# Copy thư mục build/web vào thư mục serve của nginx
COPY build/web /usr/share/nginx/html

# Expose port 5002
EXPOSE 5002

# Chạy nginx (đây là lệnh mặc định trong image nginx)
CMD ["nginx", "-g", "daemon off;"]
