### 🌐 Rofi NetworkManager Integration 📡

Welcome to the Rofi NetworkManager integration project! 🚀 This tool combines the power of Rofi and NetworkManager to create a sleek, fast, and user-friendly way to manage your Wi-Fi connections, all within a beautiful Rofi interface. 🎉
Features 🛠️

### What It Provides 📡
<div>
- Wi-Fi Management
- Signal Strength Indicator
- Customizable Interface
- Super Easy
- Custom Rofi .rasi
</div>

### 🚀 Installation
Prerequisites 📦
<div>
Before you start, make sure you have the following installed:

- Rofi 
- NetworkManager (with nmcli support)
- bash (because, well, we need it to run the script)
</div>
  
### To install them, just run:
<div>
On Arch Linux and Artix Linux:

sudo pacman -S rofi networkmanager

</div>

### Clone the Repository 🧑‍💻

Now, grab the code from GitHub (don’t worry, it’s free!):

git clone https://github.com/yourusername/rofi-networkmanager.git
cd rofi-networkmanager

### Configuration 🛠️

<div>
- Rofi Customization:
The default .rasi theme file is located at ./config/rofi-wifi.rasi. 🎨 Feel free to customize the theme to match your aesthetic. It's like a blank canvas... but with Wi-Fi! 🖼️

- Modify the Script:
The script responsible for fetching networks is in ./scripts/rofi-wifi.sh. 🖥️ Make it your own by tweaking the code or adding more awesome features!

-Set Up Rofi:
Make sure the script is executable:

        chmod +x ./scripts/rofi-wifi.sh
</div>

### 🐞 Known Issues

- Signal Strength Bug: Occasionally, the signal strength indicator shows stars 🌟 instead of a signal bar 📶. Weird, right? We’re on it! 🔧 If you find more bugs, let us know, and we’ll try to squash them like the pesky little creatures they are. 🐜

- Customization Required: The .rasi theme is a modified version of a theme from another creator. If you see anything funky in the design, scrub the code and make it yours! ✨

### 💡 Notes for Custom .rasi Scrubbing

</div>
- Don’t just copy-paste the .rasi file! 📝 If you plan to customize it, scrub through the code and remove any unnecessary parts. It’s a modified version of another creator’s file, and we don’t want to cause any conflicts. ⚔️
- Check out the original theme from the creator here if you want to see where it all began. 🙌
</div>

### 🎯 Next Steps

<div>
- Fix the stars bug: We’re still investigating why stars sometimes appear in place of the signal bar. Any contributions are welcome to fix this cosmic error! 🌌
- Make it prettier: Add more customization options to the .rasi files and make this Wi-Fi interface the most stylish thing on your desktop. 💅
</div>

### Note: This script works perfectly on Arch Linux and Artix Linux (tested and confirmed). 🎉 However, it hasn't been tested on other Linux distributions yet. If you try it on a different distro and encounter issues, feel free to open an issue, and we’ll take a look! 🚨
### Enjoy managing your Wi-Fi in style! 🎉 If you run into any problems,hesitate to open an issue on GitHub. Let’s make Wi-Fi connections fun again! 📶😄
