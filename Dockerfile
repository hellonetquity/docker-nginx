FROM nginx:1.14.2
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 443
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ADD etc /etc/
