using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using UnityEngine;
using Yodo1.MAS;

public class Yodo1AdNetworkUtil
{

    public static string TetCurSDKVersion(string versionPath)
    {
        if (string.IsNullOrEmpty(versionPath) || File.Exists(versionPath) == false)
        {
            Debug.LogError(Yodo1U3dMas.TAG + ": the versionPath is null or version.xml file is not exist!");
            return null;
        }

        XmlReaderSettings settings = new XmlReaderSettings();
        settings.IgnoreComments = true;
        XmlReader reader = XmlReader.Create(versionPath, settings);

        XmlDocument xmlReadDoc = new XmlDocument();
        xmlReadDoc.Load(versionPath);
        XmlNode xnRead = xmlReadDoc.SelectSingleNode("versions");
        XmlElement unityNode = (XmlElement)xnRead.SelectSingleNode("unity");
        string env = unityNode.GetAttribute("env").ToString();
        string version = unityNode.GetAttribute("version").ToString();
        string suffix = unityNode.GetAttribute("suffix").ToString();
        if (suffix != null && !suffix.Equals(""))
        {
            version = version + "-" + suffix;
        }
        if (!env.Equals("Release"))
        {
            version = version + "-SNAPSHOT";
        }
        reader.Close();

        return version;
    }

}
