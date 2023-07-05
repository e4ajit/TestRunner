#!/bin/bash

branch=$1
unityLicense=$2
unityUsername=$3
unityPassword=$4
dingToken=$5

license=true
if [[ ${unityLicense} == '' ]]
then
   license=false 
fi

if [[ ${unityUsername} == '' ]]
then
   license=false 
fi

if [[ ${unityPassword} == '' ]]
then
   license=false 
fi

# WORKSPACE=$(dirname $0)
WORKSPACE=$(pwd)
echo "WORKSPACE: "$WORKSPACE
cd ${WORKSPACE}

###########配置开始###########
UNITY3D_PROJECT_PATH=${WORKSPACE}
echo "UNITY3D_PROJECT_PATH: ${UNITY3D_PROJECT_PATH}"
UNITY3D_EXE_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
if [[ ${license} == false ]]
then
    UNITY3D_VERSION="2020.3.0f1c1"
    UNITY3D_EXE_PATH="/Applications/Unity/Hub/Editor/${UNITY3D_VERSION}/Unity.app/Contents/MacOS/Unity"
else
    UNITY3D_EXE_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
fi
echo "UNITY3D_EXE_PATH: "$UNITY3D_EXE_PATH
UNITY3D_EXPORT_PATH="Assets/Yodo1/Generator/Packages/"

env=$(echo 'cat //versions/unity//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
version=$(echo 'cat //versions/unity/@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
suffix=$(echo 'cat //versions/unity//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

androidEnv=$(echo 'cat //versions/android//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
androidVersion=$(echo 'cat //versions/android//@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
androidSuffix=$(echo 'cat //versions/android//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

iosEnv=$(echo 'cat //versions/ios//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
iosVersion=$(echo 'cat //versions/ios//@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
iosSuffix=$(echo 'cat //versions/ios//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

if [[ ${branch} == *master* ]]
then
    
    if [[ ! ${env} == 'Release' ]]
    then
        env="Release"
        # suffix=""
    fi    
    if [[ ! ${androidEnv} == 'Release' ]]
    then
        androidEnv="Release"
        # androidSuffix=""
    fi
    if [[ ! ${iosEnv} == 'Release' ]]
    then
        iosEnv="Release"
        # iosSuffix=""
    fi
else
    if [[ ${env} == 'Release' ]]
    then
        env="Dev"
    fi
    if [[ ${androidEnv} == 'Release' ]]
    then
        androidEnv="Dev"
    fi
    if [[ ${iosEnv} == 'Release' ]]
    then
        iosEnv="Dev"
    fi
fi

echo '<?xml version="1.0" encoding="utf-8"?>' > Assets/Yodo1/MAS/version.xml
echo '<versions>' >> Assets/Yodo1/MAS/version.xml
echo "	<unity env=\"${env}\" version=\"${version}\" suffix=\"${suffix}\"/>" >> Assets/Yodo1/MAS/version.xml
echo "	<android env=\"${androidEnv}\" version=\"${androidVersion}\" suffix=\"${androidSuffix}\"/>" >> Assets/Yodo1/MAS/version.xml
echo "	<ios env=\"${iosEnv}\" version=\"${iosVersion}\" suffix=\"${iosSuffix}\"/>" >> Assets/Yodo1/MAS/version.xml
echo '</versions>' >> Assets/Yodo1/MAS/version.xml

if [[ ! ${branch} == *master* ]]
then
    version="${version}-${suffix}"
fi

rm -rf ${UNITY3D_EXPORT_PATH}*

#执行Unity3d导出指令
# -executeMethod 指定执行的编译方法
# -projectPath 指定Unity3d项目目录
# ${UNITY3D_EXE_PATH} -batchmode -serial ${unityLicense} -username ${unityUsername} -password ${unityPassword}
# 完整版
if [[ ${license} == true ]]
then
    # 激活许可证需要时间，所以这里需要多执行一次，第一次仅仅为了激活许可证，第二次为了导出插件包
    ${UNITY3D_EXE_PATH} -batchmode -serial ${unityLicense} -username ${unityUsername} -password ${unityPassword} -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Full" -logfile ExportFullLog.log -quit
else
    ${UNITY3D_EXE_PATH} -batchmode -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Full" -logfile ExportFullLog.log -quit
fi
./ossutilmac64 cp ExportFullLog.log oss://yodo1-mas-sdk/${version}/Unity/${env}/ -c ~/.ossutilconfig -u

# Lite
if [[ ${license} == true ]]
then
    ${UNITY3D_EXE_PATH} -batchmode -serial ${unityLicense} -username ${unityUsername} -password ${unityPassword} -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Lite" -logfile ExportStandardLog.log -quit
else
    ${UNITY3D_EXE_PATH} -batchmode -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Lite" -logfile ExportStandardLog.log -quit
fi
./ossutilmac64 cp ExportStandardLog.log oss://yodo1-mas-sdk/${version}/Unity/${env}/ -c ~/.ossutilconfig -u

# 家庭版
if [[ ${license} == true ]]
then
    ${UNITY3D_EXE_PATH} -batchmode -serial ${unityLicense} -username ${unityUsername} -password ${unityPassword} -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Family" -logfile ExportFamilyLog.log -quit
else
    ${UNITY3D_EXE_PATH} -batchmode -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "Yodo1AdExportPackage.ExportPackage_Family" -logfile ExportFamilyLog.log -quit
fi
./ossutilmac64 cp ExportFamilyLog.log oss://yodo1-mas-sdk/${version}/Unity/${env}/ -c ~/.ossutilconfig -u

# 退回许可证
${UNITY3D_EXE_PATH} -quit -batchmode -returnlicense

for file in $(find ${UNITY3D_EXPORT_PATH} -maxdepth 1 -name "*.unitypackage" | sort)
do
    echo "file: ${file}"
    ./ossutilmac64 cp ${file} oss://yodo1-mas-sdk/${version}/Unity/${env}/ -c ~/.ossutilconfig -u
done

successful=1
msgTitle="Release Unity Yodo1MasSDK"
msgContent="#### ${msgTitle}\nResult: Actions Completed\nEnvironment: ${env}\nVersion: ${version}\n##### Detail"
# 发送钉钉消息
if [[ -a ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Full.unitypackage ]]
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

# if [[ -a ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Lite.unitypackage ]]
# then
#     name="Rivendell-${version}-Lite.unitypackage"
#     url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/Rivendell-${version}-Lite.unitypackage"
#     echo "${name}下载地址: ${url}"
#     msgContent="${msgContent}\n- [${name}](${url}) 成功"
# else
#     name="Rivendell-${version}-Lite.unitypackage"
#     url="https://mas-artifacts.yodo1.com/${version}/Unity/${env}/ExportStandardLog.log"
#     echo "${name}失败，日志地址: ${url}"
#     msgContent="${msgContent}\n- ${name} 失败: 请查看[日志](${url})"
#     successful=0
# fi

if [[ -a ${UNITY3D_EXPORT_PATH}Rivendell-${version}-Family.unitypackage ]]
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

echo "{\"successful\" : \"${successful}\", \"version\" : \"${version}\" }" > Yodo1Mas.json

sh android.sh

if [[ ! ${dingToken} == '' ]]
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