FROM splunk/splunk:latest

RUN sudo mkdir -p /opt/splunk/etc/apps/TA_Snort3_json/local
COPY ./inputs.conf /opt/splunk/etc/apps/TA_Snort3_json/local/

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start-service"]