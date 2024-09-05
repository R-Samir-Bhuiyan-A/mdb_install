
## Installation for linux
you can download and install it from the [Node.js website](https://nodejs.org/). or use the script 

 
## Installation Script

The installation script sets up the MDB environment by installing necessary packages, Node.js, and configuring services and Nginx. It also provides options for different Node.js versions and configures the environment with user input.

### Run the Installation Script

To download and run the installation script, use the following command:

```bash
wget https://github.com/R-Samir-Bhuiyan-A/mdb_install/releases/download/install/install.sh && bash install.sh
```



### Run the uninstallation Script

To download and run the uninstallation script, use the following command:

```bash
wget https://github.com/R-Samir-Bhuiyan-A/mdb_install/releases/download/uninstall/uninstall.sh && bash uninstall.sh
```

1. panel start
    ```bash
    systemctl start mdb
    ```

2. panel stop
     ```bash
     systemctl stop mdb
     ```
3. panel restart
     ```bash
     systemctl restart mdb
     ```

4. api demon start
    ```bash
    systemctl start mdbr
    ```

5. api demon stop
     ```bash
     systemctl stop mdbr
     ```
6. api demon restart
     ```bash
     systemctl restart mdbr
     ```     


   

5. Visit `io/domain:port` in your web browser to set up the required environment variables (`IP`, `PORT`, `BOTNAME`, `PASSWORD`, `VERSION`, `SERVER_PORT`, `WS_PORT`). These variables are necessary for the bot to function properly.


## Installation for Windows 

To use this bot, ensure you have Node.js installed on your system. If not, you can download and install it from the [Node.js website](https://nodejs.org/)

1. DOWNLOAD the latest [release](https://github.com/R-Samir-Bhuiyan-A/minecraft-kit-bot/releases/download/mdb2.0/MDB.zip)
2. unzip it  
3. Install modules needed for this by running in cmd ( on the folder where you unziped it)
     ```bash
     npm install 
     ```
 4. To start the bot
      ```bash
     node server.js 
     ```   
## HOW to make it auto start in windows 

1. Press Win + R to open the Run dialog.
2. Type
  ```bash
    shell:startup  
   ```
and press Enter.
3. make mdb.bat in startup 
4. And paste this
 ```bash
node /path/to/server.js
```

