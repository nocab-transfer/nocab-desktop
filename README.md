
<h1 align="center">
<img src="https://raw.githubusercontent.com/NoCabTransfer/.github/main/profile/icon.png" alt="NoCab Transfer" width="70"></a>
    <br>
<b>NoCab Desktop</b>
</h1>

<p align="center">
    NoCab Desktop is NoCab Client for desktop file transfer.
</p>

<p align="center">
    If you tired to carrying unnecessary cables or sending files to empty whatsapp groups. NoCab Transfer is for you! You can transfer all your files between your phone and your computer and your files will not be sent any other server. Just you and your devices 🤫
</p>

<p align="center">
  <a href="https://github.com/nocab-transfer/nocab-desktop/releases"><img src="https://img.shields.io/github/v/release/nocab-transfer/nocab-desktop?color=blueviolet"/></a>
  <a href="https://github.com/nocab-transfer/nocab-desktop/blob/main/LICENSE"><img src="https://img.shields.io/github/license/nocab-transfer/nocab-desktop?color=red"/></a>
</p>

<br>

<center><img src="Resources/confirmation.png" alt="NoCab Transfer" width="800"></a></center>

## Minimum Requirements
* Windows 10 1903 or later
* Android 5.0 or later [_(NoCab Mobile)_](https://github.com/nocab-transfer/nocab-mobile)
* A network that both devices are connected to

## Installing
> **Note**: Unfortunately there is no Linux or MacOS Application. For Windows keep reading.

### 1. Installing MSIX using PowerShell
* Right click the Windows button and select PowerShell or Terminal.
* Run the following command \
    `irm https://get-nocab.netlify.app | iex`
* Wait for the installation to complete
* You can now use the NoCab 🥳🚀

> **Note**: What is `get-nocab.netlify.app`? Read more about it [here](https://github.com/nocab-transfer/nocab-desktop/wiki/Possible-Questions#so-what-is-get-nocabnetlifyapp)

### 2. Downloading Portable Version
* Download the `nocab_desktop-win64-portable.zip` from [here](https://github.com/nocab-transfer/nocab-desktop/releases/latest)
* Extract the zip file to a folder
* Run the nocab_desktop.exe file
* Now you are ready to go 🥳🚀

> **Note**: We recommend you to use the MSIX version. Read more about why [here](https://github.com/nocab-transfer/nocab-desktop/wiki/Why-you-should-use-MSIX%3F).

## How to build
1. Installations
    1. Install [Flutter](https://flutter.dev/docs/get-started/install) 
    2. For windows development, you need to install [Visual Studio](https://visualstudio.microsoft.com/downloads/) with `Desktop development with C++` workload. \
    Read more [here](https://docs.flutter.dev/development/platform-integration/windows/building)
2. Switch to the `master` channel of Flutter
    * `flutter channel master`
3. Clone the repository and go to the directory
    * `git clone https://github.com/nocab-transfer/nocab-desktop.git`
    * `cd nocab-desktop`
5. Get the dependencies
    * `flutter pub get`
6. Generate the code
    * `flutter pub run build_runner build`
7. Run the app
    * `flutter run`

<br>
<h1 align="center">
ScreenShots
</h1>

<table align= "center">
    <tr>
        <td colspan>
            <p align="center">Transfer List</p>
            <img src="Resources/transferList.png" width="400">
        </td>
        <td colspan>
            <p align="center">Send Dialog</p>
            <img src="Resources/sendDialog.png" width="400">
        </td>
    </tr>
    <tr>
        <td colspan>
            <p align="center">History</p>
            <img src="Resources/history.png" width="400">
        </td>
        <td colspan>
            <p align="center">Settings</p>
            <img src="Resources/settings.png" width="400">
        </td>
    </tr>
</table>