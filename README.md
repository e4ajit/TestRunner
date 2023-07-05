# Yodo1 MAS Unity Plugin

## Overview
MAS is Yodo1's in-app monetization solution.

Please check out the [documentation](https://developers.yodo1.com/article-categories/sdk-docs/) to get started on integrating.

## Workflow with DS team

1. Documentation
In order to better optimize the technical team and DS team workflow, we are using GitHub as a mediator to management and tracking change record.

	* The technical team is responsible for updating the content to GitHub and submitting the PR to the DS Team, 
	* The DS team is responsible for updating the PR content to Official document

## How to build the unitypackages and upload to OSS

1. For Github Action: It will automatically build unitypackages and upload to Aliyun OSS
2. For manual, please following below steps
	* Open the terminal and enter the root directory of the project
	* Check `.ossutilconfig` file, If not, please excute the following command to generate the file

		```shell
		./ossutilmac64 config
		```
   		* Use the default file path
		* OSS's KEYs
	
		| Key             | Value                          |
		| :-------------- | ------------------------------ |
		| endpoint        | oss-accelerate.aliyuncs.com    |
		| accessKeyID     | LTAI5tCgCh2jmoUXcQaiymbf       |
		| accessKeySecret | reDA13V5253om6wA2NTg028TE0ZYuG |

	* Modify the SDK version configuration file, `Assets/Yodo1/MAS/version.xml`
		
		```xml
		<?xml version="1.0" encoding="utf-8"?>
		<versions>
			<unity env="Pre" version="4.5.0" suffix="beta-02" />
			<android env="Pre" version="4.5.0" suffix="beta-02" />
			<ios env="Pre" version="4.5.0" suffix="beta-02" />
		</versions>
		```

	* Excute the following command to generate the unitypackages, you can find the new unitypackages in the `/Assets/Yodo1/Generator/Packages` folder
		
		```shell
		sh export.sh
		```
	* Upload the unitypackages to Aliyun OSS, [ossBrowser](https://help.aliyun.com/document_detail/209974.html) can be used to upload resources

### Reference

[Official document](https://developers.yodo1.com/article-categories/unity/) |
[GitHub document](https://github.com/Yodo1Games/MAS-Documents/blob/main/markdowns/integration-unity.md) |
[Demo App](https://github.com/Yodo1Games/Yodo1-MAS-Unity-Plugin-Demo) |
[Notion Change Log](https://www.notion.so/yodo1-mo/32ecad7498f54fe1bc72d3f12472664b?v=7c9a0c37fe7247379f6ce843bd3401ec) |
[Notion SDK Team](https://www.notion.so/yodo1-mo/SDK-Team-10838a0e133b4c398504b23cbbea12f4)