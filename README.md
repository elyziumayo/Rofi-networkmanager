### 🌐 Rofi NetworkManager Integration 

Welcome to the Rofi NetworkManager integration project! 🚀 This tool combines the power of Rofi and NetworkManager to create a sleek, fast, and user-friendly way to manage your Wi-Fi connections, all within a beautiful Rofi interface. 🎉
Features 🛠️

### 🚀 Installation
Prerequisites 📦
<div>

 Before you start, make sure you have the following installed:

- Rofi 
- NetworkManager (with nmcli support)
- bash (because, well, we need it to run the script)
- ttf-jetbrains-mono-nerd
- otf-font-awesome
- Swaync or any notification menue
</div>
  
### ⚙️ To install them, just run:
<div>

On Arch Linux and Artix Linux:

 ```bash
sudo pacman -S rofi networkmanager swaync otf-font-awesome ttf-jetbrains-mono-nerd
 ```
</div>

### 🧑‍💻 Clone the Repository

Now, grab the code from GitHub (don’t worry, it’s free!):

```bash
git clone https://github.com/elysiumayo/Rofi-networkmanager.git
cd Rofi-networkmanager
```
Move the 'Scripts' folder to home directory 
### 🛠️ Configuration

<div>

 - Rofi Customization:
The default rofi theme for my script is located at ~/Scripts/wifi.rasi. 🎨 Feel free to customize the theme to match your aesthetic. It's like a blank canvas... but with Wi-Fi! 🖼️ , The .rasi theme is a modified version of a theme from [Adi1090x](https://github.com/adi1090x/rofi.git). If you see anything funky in the design, scrub the code and make it yours! ✨

- Modify the Script:
The script responsible for fetching networks is in ./scripts/rofi-wifi.sh. 🖥️ Make it your own by tweaking the code or adding more awesome features!


Make sure the script is executable:

```bash
chmod +x ~/Scripts/network.sh
 ```

</div>

### 🐞 Known Issues
 - Find and raise issue 

