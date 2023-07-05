#!/bin/bash
branch=$1
dingToken=$2

env=$(echo 'cat //versions/unity//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
version=$(echo 'cat //versions/unity/@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
suffix=$(echo 'cat //versions/unity//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

echo "ENV: ${env}, VERSION: ${version}, SUFFIX: ${suffix}"

if [[ ${suffix} != '' ]]
then
    version="${version}-${suffix}"
fi

echo "FULL-VERSION: ${version}"

UNITY3D_EXPORT_PATH="Assets/Yodo1/Generator/Packages/"

for file in $(find ${UNITY3D_EXPORT_PATH} -maxdepth 1 -name "*.unitypackage" | sort)
do
    echo "file: ${file}"
    ./ossutil64 cp ${file} oss://yodo1-mas-sdk/${version}/Unity/${env}/ -c ~/.ossutilconfig -u
done

successful=1
msgTitle="Release Unity Yodo1MasSDK"
msgContent="#### ${msgTitle}\nResult: Actions Completed\nEnvironment: ${env}\nVersion: ${version}\n##### Detail"
# 发送钉钉消息
if [[ -f ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Full.unitypackage ]]
then
    name="Rivendell-${version}-Full.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/Rivendell-${version}-Full.unitypackage"
    echo "${name}下载地址: ${url}"
    msgContent="${msgContent}\n- [${name}](${url}) 成功"
else
    name="Rivendell-${version}-Full.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/ExportFullLog.log"
    echo "${name}失败，日志地址: ${url}"
    msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](${url})"
    successful=0
fi

if [[ -f ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Family.unitypackage ]]
then
    name="Rivendell-${version}-Family.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/Rivendell-${version}-Family.unitypackage"
    echo "${name}下载地址: ${url}"
    msgContent="${msgContent}\n- [${name}](${url}) 成功"
else
    name="Rivendell-${version}-Family.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/ExportFamilyLog.log"
    echo "${name}失败，日志地址: ${url}"
    msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](${url})"
    successful=0
fi

if [[ -f ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Lite.unitypackage ]]
then
    name="Rivendell-${version}-Lite.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/Rivendell-${version}-Lite.unitypackage"
    echo "${name}下载地址: ${url}"
    msgContent="${msgContent}\n- [${name}](${url}) 成功"
else
    name="Rivendell-${version}-Lite.unitypackage"
    url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/ExportLiteLog.log"
    echo "${name}失败，日志地址: ${url}"
    msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](${url})"
    successful=0
fi

echo "{\"successful\" : \"${successful}\", \"version\" : \"${version}\" }" > Yodo1Mas.json

if [[ ${dingToken} != '' ]]
then
    curl "https://oapi.dingtalk.com/robot/send?access_token=${dingToken}" -H "Content-Type: application/json" -d "{\"msgtype\": \"markdown\",\"markdown\": {\"title\":\"Actions:${msgTitle}\",\"text\":\"${msgContent}\",\"at\":{\"isAtAll\":true}}}"
else
    echo 'dingToken为空，无法发送钉钉消息'
fi

echo ******************************
if [ $? -ne 0 ]; then
    echo Export Command is FAILED
else
    echo Export Command is SUCCESSFUL
fi
echo ******************************