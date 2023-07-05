#!/bin/bash

branch=$1

env=$(echo 'cat //versions/unity//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
version=$(echo 'cat //versions/unity/@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
suffix=$(echo 'cat //versions/unity//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

androidEnv=$(echo 'cat //versions/android//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
androidVersion=$(echo 'cat //versions/android//@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
androidSuffix=$(echo 'cat //versions/android//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

iosEnv=$(echo 'cat //versions/ios//@env' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
iosVersion=$(echo 'cat //versions/ios//@version' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')
iosSuffix=$(echo 'cat //versions/ios//@suffix' | xmllint --shell Assets/Yodo1/MAS/version.xml | awk -F'[="]' '!/>/{print $(NF-1)}')

if [[ "${branch}" == *master* ]];then
    if [[ "${env}" != 'Release' ]]
    then
        env="Release"
        # suffix=""
    fi    
    if [[ ${androidEnv} != 'Release' ]]
    then
        androidEnv="Release"
        # androidSuffix=""
    fi
    if [[ ${iosEnv} != 'Release' ]]
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