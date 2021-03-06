#!/bin/bash
# Generate project configs before running commands
set -e
if [ x"${VHOSTS}" != x"" ]; then
  # parsing stuff with read can have its downsides
  # always check your input values and generated configs in case of any issues
  # we expect comma-separated,key=value dict here
  # e.g. VHOSTS="www.host1.com=service1,www.host2.com=service2"
  IFS=',' read -ra HOSTS_LIST <<< "$VHOSTS"
  for elem in "${HOSTS_LIST[@]}"; do
    IFS='=' read -r FQDN PROXIED_SERVICE <<< "$elem"
    export FQDN
    export PROXIED_SERVICE
    if [ -z "${PROXIED_SERVICE##*web}" ]; then
      envsubst '\$FQDN \$PROXIED_SERVICE' < /etc/nginx/conf.d/slowbackend.conf.tmpl > /etc/nginx/conf.d/"${FQDN}".conf
    else
      envsubst '\$FQDN \$PROXIED_SERVICE' < /etc/nginx/conf.d/project.conf.tmpl > /etc/nginx/conf.d/"${FQDN}".conf
    fi
  done
  # Unconditional 301 redirects (mainly for www/bare)
  # same format but target has to be full url (with https:// and all)
  # NOTE: no trailing slash!
  if [ x"${REDIRECTS}" != x"" ]; then
    IFS=',' read -ra HOSTS_LIST <<< "$REDIRECTS"
    for elem in "${HOSTS_LIST[@]}"; do
      IFS='=' read -r FQDN TARGET <<< "$elem"
      export FQDN
      export TARGET
      envsubst '\$FQDN \$TARGET' < /etc/nginx/conf.d/redirect.conf.tmpl > /etc/nginx/conf.d/"${FQDN}".conf
    done
  fi
else
  # Backward compatibility, single virtual host
  # (assuming FQDN/PROXIED_SERVICE are set)
  envsubst '\$FQDN \$PROXIED_SERVICE' < /etc/nginx/conf.d/project.conf.tmpl > /etc/nginx/conf.d/project.conf
fi

exec "$@"
