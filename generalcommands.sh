/root/LogAnalyticsDemoSetup/filebeat/filebeat -e -c /root/LogAnalyticsDemoSetup/filebeat/filebeat.yml
/root/LogAnalyticsDemoSetup/flog/flog -f apache_combined -n 20 >> /root/LogAnalyticsDemoSetup/apache_combined.log
