FROM python:3-alpine as mkdocs-generator

WORKDIR /knowledge-base

COPY ./knowledge-base-dir/docs /knowledge-base/docs
COPY ./knowledge-base-dir/requirements.txt /knowledge-base/requirements.txt
COPY ./knowledge-base-dir/mkdocs.yml .

RUN pip install -r requirements.txt
RUN mkdocs build

FROM nginx

COPY ./knowledge-base-dir/nginx.conf /etc/nginx/conf.d/configfile.template
COPY --from=mkdocs-generator /knowledge-base/site /usr/share/nginx/html

CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"