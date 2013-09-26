#!/bin/bash

tool="wpro"

cd data

rm -f *.json worldN.zip world FO.zip FO.swf

$tool "http://www.fantasy-mmorpg.com/fowiki/json/item.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/itemtoquest.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/mob.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/mobdrops.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/mobtoquest.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/npc.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/npctoquest.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/npctorecipe.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/npcsonmap.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/dialog.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/questinitiator.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/spell.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/recipe.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/zonemonster.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/listing.json"
$tool "http://www.fantasy-mmorpg.com/fowiki/json/marketchart.json"

$tool "http://www.fantasystatic.com/inc/rpc/worldI.zip" && unzip -o worldI.zip
$tool "http://www.fantasystatic.com/rest/FO.zip" && mv FO.zip FO.swf
$tool "http://www.fantasy-mmorpg.com/FO88.swf"
