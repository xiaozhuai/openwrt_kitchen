echo "- Prepare opkg"
cp -f /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
sed -i 's/https:/http:/' /etc/opkg/distfeeds.conf
opkg update
opkg install ca-bundle ca-certificates wget-ssl
mv -f /etc/opkg/distfeeds.conf.bak /etc/opkg/distfeeds.conf
