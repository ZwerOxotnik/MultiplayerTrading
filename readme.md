
![thumbnail](/thumbnail.png?raw=true)

# Contents

* [Description](#description)
    * [Sell Box](#sell-box)
    * [Buy Box](#buy-box)
    * [Electric Trading Station](#electric-trading-station)
    * [Credit Mint](#credit-mint)
* [Optional Systems](#credit-mint)
    * [Land Claim](#land-claim)
    * [Specializations](#specializations)
    * [Early Bird Technology](#early-bird-technology)
* [Terms of use](#terms-of-use)
* [Credit](#credit)
* [Disclaimer](#disclaimer)

# Description

Intended for use in multiplayer games with multiple forces, i.e. the PvP scenario.\
Best experienced alongside the Lawful Evil mod

Forces can buy and sell items for credits via buy-boxes and sell-boxes.

## <a name="sell-box"></a> Sell Box

This upgraded steel chest has a single slot. Open it to set what item it sells and how much to sell it for. Sell boxes will automatically sell to adjacent buy boxes (within 3 tiles distance).

## <a name="buy-box"></a> Buy Box

Also has a single slot. Open it to set what item it buys and how much your force will pay per item. Buy Boxes will automatically buy the filtered item from adjacent sell boxes (withing 3 tiles distance), so long as the asking price is equal to or higher than the selling price. The highest price between the buy and sell boxes will always be used.

## <a name="electric-trading-station"></a> Electric Trading Station

Allows the trade of energy between energy networks belonging to different forces. Electric trading stations sell energy to other adjacent stations (within 3 tiles distance). These both automatically buy and sell energy, depending on supply and demand. Set the sell price of your force's energy, and a bid price, which is how much your force is willing to pay for energy (per MW). Energy is only transferred if the bid price is greater than or equal to their sell price.

There can be more than 2 Electric Trading Stations adjacent to each other, in which case the energy will go to the highest bidder.

## <a name="credit-mint"></a> Credit Mint

A building that slowly generates credits from power. Consumes 2MW (can be changed in mod settings).

# <a name="optional-systems"></a> Optional Systems

Multiplayer Trading also comes with some extra systems that are designed to incentivize trading. You may turn these off from the mod settings.

## <a name="land-claim"></a> Land Claim

Players cannot build anywhere on the map. Land must be claimed before things can be built. Claiming land is done by placing any of the 4 types of electric poles. All land within the poles electric supply radius will be claimed. There are some exceptions for land that has no claim, called No Mans Land. In No Mans Land anyone can still build belts, pipes, poles and rail. Anyone can build buy and sell boxes anywhere, even on opponents claimed land.

Claiming land costs 1 credit per tile. Removing a pole gives a 100% percent refund.

The supply radius and cable reach of all electric poles are doubled when Land Claim is enabled.

## Specializations

A force can specialize in the production of a specific item by increasing their production rate. For example, a force can specialize in Iron Gear Wheels by being the first to reach 1K Iron Gear Wheels / min. When you unlock a specialization you gain a more efficient recipe for the item and no other force can gain that specialization.

Open the Specialization window with the key 'J'.

Recipes will need to be changed manually in assembly machines once a specialization has been unlocked.

## <a name="early-bird-technology"></a> Early Bird Technology

For some technologies there is a benefit to researching it first: it's cheaper. Once a force has researched a technology it becomes more expensive for everyone else. The cost keeps going up for the 2nd, 3rd and 4th in line.

This only applies to leafs in the technology tree. That is tech that is not listed as a prerequisite for any other tech. This is limitation of the modding api, and keeps the tech tree gui fully functional.

# <a name="terms-of-use"></a> Terms of use

Copyright (c) 2019 Luke Perkin (https://github.com/perky)
Modification Copyright (c) 2019-2020, 2024 ZwerOxotnik (https://github.com/ZwerOxotnik) <zweroxotnik@gmail.com>

[![Creative Commons License](https://licensebuttons.net/l/by/4.0/88x31.png)](https://creativecommons.org/licenses/by/4.0/)

This work is a derivative of "Multiplayer Trading" by Luke Perkin, used under [Creative Commons Attribution 4.0 Unported license](https://creativecommons.org/licenses/by/4.0/). This work is attributed to Luke Perkin and ZwerOxotnik, and the original version can be found [here](https://mods.factorio.com/mod/multiplayertrading).

This work is licensed under a [Creative Commons Attribution 4.0 International License](/LICENSE).

# Credit

Credit to DragoNFly1 and ZwerOxotnik, MPT takes some concepts from their mods.

# Disclaimer

THE WORK IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE WORK OR THE USE OR OTHER DEALINGS IN THE
WORK.
