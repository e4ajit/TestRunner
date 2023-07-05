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
if [[ ${branch} == '' ]]
then
    UNITY3D_VERSION="2020.3.0f1c1"
    UNITY3D_EXE_PATH="/Applications/Unity/Hub/Editor/${UNITY3D_VERSION}/Unity.app/Contents/MacOS/Unity"
else
    UNITY3D_EXE_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
fi
echo "UNITY3D_EXE_PATH: "$UNITY3D_EXE_PATH
UNITY3D_EXPORT_PATH="Assets/Yodo1/Generator/Packages/"

env=$(echo 'cat //versions/android//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
version=$(echo 'cat //versions/android//@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
suffix=$(echo 'cat //versions/android//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

if [[ ! ${branch} == *master* ]]
then
    version="${version}-${suffix}"
fi

if [[ ${license} == true ]]
then
    # 激活许可证需要时间，所以这里需要多执行一次，第一次仅仅为了激活许可证，第二次为了导出插件包
    ${UNITY3D_EXE_PATH} -batchmode -serial ${unityLicense} -username ${unityUsername} -password ${unityPassword} -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "GooglePlayServices.PlayServicesResolver.MenuForceResolve" -logfile ExportAndroidLog.log -quit
else
    ${UNITY3D_EXE_PATH} -batchmode -projectPath ${UNITY3D_PROJECT_PATH} -executeMethod "GooglePlayServices.PlayServicesResolver.MenuForceResolve" -logfile ExportAndroidLog.log -quit
fi

if [ ! -d Yodo1MasSdk ]
then
    mkdir Yodo1MasSdk
fi

for file in $(find ./Assets/Plugins/Android -maxdepth 1 -name "*.aar" | sort)
do
    cp -f ${file} Yodo1MasSdk
done

for file in $(find ./Assets/Plugins/Android -maxdepth 1 -name "*.jar" | sort)
do
    cp -f ${file} Yodo1MasSdk
done

if [ "`ls -A Yodo1MasSdk`" = "" ]
then
    echo "编译失败aar文件不存在"
    ./ossutilmac64 cp ExportAndroidLog.log oss://yodo1-mas-sdk/${version}/Android/${env}/ -c ~/.ossutilconfig -u
else
    zip -r Yodo1MasSdk-${version}.zip Yodo1MasSdk
    ./ossutilmac64 cp Yodo1MasSdk-${version}.zip oss://yodo1-mas-sdk/${version}/Android/${env}/ -c ~/.ossutilconfig -u
    msgTitle="Release Unity Yodo1MasSDK"
    msgContent="#### ${msgTitle}\nResult: AAR Completed\nEnvironment: ${env}\nVersion: ${version}\n##### Detail:\n Android AAR[下载地址](https://mas-artifacts.yodo1.com/${version}/Android/${env}/Yodo1MasSdk.zip"
    if [[ ! ${dingToken} == '' ]]
    then
        curl "https://oapi.dingtalk.com/robot/send?access_token=${dingToken}" -H "Content-Type: application/json" -d "{\"msgtype\": \"markdown\",\"markdown\": {\"title\":\"Actions:${msgTitle}\",\"text\":\"${msgContent}\",\"at\":{\"isAtAll\":true}}}"
    else
        echo 'dingToken为空，无法发送钉钉消息'
    fi
fi
