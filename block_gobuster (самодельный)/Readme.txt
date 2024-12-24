Block_gobuster.sh - самодельный скрипт который проверяет наличие брутфорса скрытых директорий от подозрительного пользователя, используется для ubuntu server  Установка: sudo apt update
sudo apt install iptables whois apache2 //apache2 только если его нету
sudo mkdir -p /usr/local/bin
Вставляем этот файл в созданную папку
sudo chmod +x /usr/local/bin/block_gobuster.sh

Запуск скрипта:
nohup /usr/local/bin/block_gobuster.sh &
ps aux | grep block_gobuster.sh // проверяем работает ли он


Остановка скрипта:
sudo killall block_gobuster.sh


Если код будет видеть что кто то пытается забрудфорсить директории сайта, то он автоматически блокирует ему доступ к нему и выводит в терминал уведомление:
$(date): Заблокирован IP $IP" >> "$BLOCK_LOG"
Whois information for $IP:" >> "$BLOCK_LOG" //Здесь будет выводиться полная информация, которую можно вытащить с ip адреса
$WHOIS_INFO" >> "$BLOCK_LOG"
----------------------------------" >> "$BLOCK_LOG"

Также всех заблокированные ip можно просмотреть используя команду: 
/usr/local/bin/block_gobuster.sh list

Также можно просмотреть отдельно полные логи блокировок с ip и его полной информацией через файл:
Sudo nano /var/log/apache2/blocked_ips.txt

При желании можно разблокировать ip используя команду 
/usr/local/bin/block_gobuster.sh unblock <ip>
