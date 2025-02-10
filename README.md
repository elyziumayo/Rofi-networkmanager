# 🌐 Rofi Network Manager

<div align="center">

![Rofi Network Manager](https://img.shields.io/badge/WiFi-Manager-00C7FF?style=for-the-badge&logo=wifi&logoColor=white)
![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Powered by Coffee](https://img.shields.io/badge/Powered%20by-Coffee-brown?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white)

*Because life's too short for command-line WiFi management* 🚀

</div>

## 🎭 What's This Sorcery?

A sleek, modern network manager that turns the mundane task of connecting to WiFi into a delightful experience. Built with Rofi, it's like having a GUI but cooler - because everything's cooler in a terminal! 😎

## ✨ Features

- 🔍 **Smart Network Discovery** - Finds networks faster than your cat chasing a laser pointer
- 🔐 **Secure Connection Handling** - Keeps your data safer than your secret cookie stash
- 🎨 **Beautiful Rofi Integration** - Because we believe in making terminals pretty
- 💾 **Saved Networks Management** - Remember that one WiFi from that one café? We do!
- 🕵️ **Hidden Network Support** - For those who like to play hide and seek with their WiFi
- 🔄 **Quick Network Toggle** - On/Off faster than your New Year's resolutions

## 🛠️ Prerequisites

```bash
# You'll need these bad boys
networkmanager   # Because we need to actually connect to networks
rofi            # The pretty menu maker
notify-send     # For those sweet notifications
ttf-jetbrains-mono-nerd
otf-font-awesome
```

## 🚀 Installation

1. Clone this repo (or download it, we don't judge)
```bash
git clone https://github.com/elysiumayo/Rofi-networkmanager.git
```

2. Make it executable (give it superpowers)
```bash
chmod +x network.sh
```

3. Run it like you mean it
```bash
./network.sh
```

## 🎮 Usage

Just run the script and you'll be greeted with a beautiful menu that lets you:
- 📶 Connect to WiFi networks
- 🔒 Handle secured networks with style
- 🕶️ Connect to hidden networks (very sneaky)
- 📝 Manage saved networks
- 🔌 Toggle networking on/off

## 🎨 Customization

The script uses a custom Rofi theme (`wifi.rasi`) inspired by [Adi1090x's](https://github.com/adi1090x/rofi) amazing collection. 

> 🎨 **Theme Credit:** The beautiful Rofi theme used in this project is based on [Adi1090x's Rofi Collection](https://github.com/adi1090x/rofi.git). Check out their repository for more awesome themes and customizations!

Make it yours! Change colors, fonts, or add more unicorns 🦄 - we won't stop you!

## 🐛 Troubleshooting

- **Q:** Why isn't it working?
- **A:** Did you try turning it off and on again? No, seriously, try `nmcli networking off && nmcli networking on`

- **Q:** The WiFi list is empty!
- **A:** Your WiFi adapter might be having an existential crisis

## 🤝 Contributing

Found a bug? Want to add a feature? Have a better joke? Pull requests are welcome!

## 🙏 Acknowledgments

- Coffee ☕ - The real MVP
- The person reading this - You're awesome!
- My WiFi router - For being reliable (most of the time)

---

<div align="center">

Made with 💻 and excessive amounts of ☕

*"Because managing networks shouldn't feel like debugging a printer"*

</div> 
