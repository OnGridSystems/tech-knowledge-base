FROM python:3-alpine as mkdocs-generator

WORKDIR /knowledge-base-private

COPY ./knowledge-base-private/docs ./docs
COPY ./knowledge-base-private/requirements.txt ./requirements.txt
COPY ./knowledge-base-private/mkdocs.yml .

RUN pip install -r requirements.txt
RUN mkdocs build

WORKDIR /knowledge-base-public

RUN mkdir -p /knowledge-base-public/docs
COPY ./knowledge-base-public/docs ./docs
COPY ./knowledge-base-private/requirements.txt ./requirements.txt
COPY ./knowledge-base-private/mkdocs.yml .

RUN pip install -r requirements.txt
RUN mkdocs build

FROM nginx

COPY ./knowledge-base-private/nginx.conf /etc/nginx/conf.d/configfile.template

RUN sed -i 's/# server_names_hash_bucket_size.*;$/server_names_hash_bucket_size 64;/' /etc/nginx/nginx.conf
RUN mkdir -p /usr/share/nginx/html/public && mkdir /usr/share/nginx/html/private
COPY --from=mkdocs-generator /knowledge-base-public/site /usr/share/nginx/html/public
COPY --from=mkdocs-generator /knowledge-base-private/site /usr/share/nginx/html/private
RUN cat /etc/nginx/conf.d/default.conf

CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"