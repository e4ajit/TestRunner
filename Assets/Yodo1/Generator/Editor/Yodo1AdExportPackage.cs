using System.Collections.Generic;
using System.Xml;
using UnityEditor;
using System.IO;
using Debug = UnityEngine.Debug;

public class Yodo1AdExportPackage : Editor
{
    private static readonly string RELEASE_PATH = Path.GetFullPath(".") + "/Assets/Yodo1/Generator/Packages";
    private static readonly string TARGET_PATH = Path.GetFullPath(".") + "/Assets/Yodo1/MAS/Editor/Dependencies/";
    private static readonly string VERSION_PATH = Path.GetFullPath(".") + "/Assets/Yodo1/MAS/version.xml";

    static readonly string[] validPath = {
        "ExternalDependencyManager",
        "Plugins/Android/Yodo1Ads",
        "Plugins/iOS/Yodo1MasUnityBridge",
        "Yodo1/MAS",
    };

    [MenuItem("Yodo1/MAS/MAS Export Unity Package/Lite")]
    public static void ExportPackage_Lite()
    {
        string edition = "Lite";
        UpdateDependencies("Android", edition);
        UpdateDependencies("iOS", edition);
        ExportPackage(edition);
    }

    [MenuItem("Yodo1/MAS/MAS Export Unity Package/Full")]
    public static void ExportPackage_Full()
    {
        string edition = "Full";
        UpdateDependencies("Android", edition);
        UpdateDependencies("iOS", edition);
        ExportPackage(edition);
    }

    [MenuItem("Yodo1/MAS/MAS Export Unity Package/Family")]
    public static void ExportPackage_Family()
    {
        string edition = "Family";
        UpdateDependencies("Android", edition);
        UpdateDependencies("iOS", "Full");
        ExportPackage(edition);
    }

    private static List<string> Director(string dirs)
    {
        List<string> list = new List<string>();
        FileSystemInfo[] fileInfos = new DirectoryInfo(dirs).GetFileSystemInfos();

        foreach (FileSystemInfo fsinfo in fileInfos)
        {
            string path = fsinfo.FullName;
            if (fsinfo is DirectoryInfo)
            {
                list.AddRange(Director(path));
            }
            else
            {
                foreach (string valid in validPath)
                {
                    if (path.Contains(valid))
                    {
                        string relativePath = path.Replace(Path.GetFullPath(".") + "/", "");
                        Debug.LogWarning(relativePath);
                        list.Add(relativePath);
                    }
                }
            }
        }
        return list;
    }

    private static List<string> GetAssetPathFromDirector()
    {
        string root = Path.GetFullPath(".") + "/Assets/";
        Debug.LogWarning("Root Path: " + root);
        return Director(root);
    }

    private static void ExportPackage(string edition)
    {
        if (Directory.Exists(RELEASE_PATH) == false)
        {
            Directory.CreateDirectory(RELEASE_PATH);
        }

        XmlReaderSettings settings = new XmlReaderSettings();
        settings.IgnoreComments = true;//忽略文档里面的注释
        XmlReader reader = XmlReader.Create(VERSION_PATH, settings);

        XmlDocument xmlReadDoc = new XmlDocument();
        xmlReadDoc.Load(VERSION_PATH);
        XmlNode xnRead = xmlReadDoc.SelectSingleNode("versions");
        XmlElement unityNode = (XmlElement)xnRead.SelectSingleNode("unity");
        string env = unityNode.GetAttribute("env").ToString();
        string version = unityNode.GetAttribute("version").ToString();
        string suffix = unityNode.GetAttribute("suffix").ToString();
        if (suffix != null && !suffix.Equals(""))
        {
            version = version + "-" + suffix;
        }
        reader.Close();

        string packagePath = RELEASE_PATH + "/" + string.Format("Rivendell-{0}-{1}.unitypackage", version, edition);
        if (File.Exists(packagePath))
        {
            File.Delete(packagePath);
        }
        List<string> list = GetAssetPathFromDirector();

        ExportPackageOptions op = ExportPackageOptions.Default;
        AssetDatabase.ExportPackage(list.ToArray(), packagePath, op);
        AssetDatabase.Refresh();
    }


    private static void UpdateDependencies(string platform, string edition)
    {
        Debug.Log(string.Format("[Yodo1 Mas] Update {0} dependencies {1}", platform, edition));

        string name = string.Empty;
        if (platform.Equals("Android"))
        {
            name = "Yodo1MasAndroidDependencies.xml";
        }
        if (platform.Equals("iOS"))
        {
            name = "Yodo1MasiOSDependencies.xml";
        }
        if (!string.IsNullOrEmpty(name))
        {
            string destFile = TARGET_PATH + name;
            if (File.Exists(destFile))
            {
                File.Delete(destFile);
                File.Delete(destFile + ".meta");
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            XmlReaderSettings settings = new XmlReaderSettings();
            settings.IgnoreComments = true;//忽略文档里面的注释
            XmlReader reader = XmlReader.Create(VERSION_PATH, settings);

            XmlDocument xmlReadDoc = new XmlDocument();
            xmlReadDoc.Load(VERSION_PATH);
            XmlNode xnRead = xmlReadDoc.SelectSingleNode("versions");


            XmlDocument xmlWriteDoc = new XmlDocument();
            XmlDeclaration Declaration = xmlWriteDoc.CreateXmlDeclaration("1.0", "utf-8", null);
            XmlNode dependencies = xmlWriteDoc.CreateElement("dependencies");

            if (platform.Equals("Android"))
            {
                XmlElement androidNode = (XmlElement)xnRead.SelectSingleNode("android");
                string env = androidNode.GetAttribute("env").ToString();
                string version = androidNode.GetAttribute("version").ToString();
                string suffix = androidNode.GetAttribute("suffix").ToString();

                if (suffix != null && !suffix.Equals(""))
                {
                    version = version + "-" + suffix;
                }
                if (!env.Equals("Release"))
                {
                    version = version + "-SNAPSHOT";
                }
                string model = string.Empty;
                if (edition.Equals("Family"))
                {
                    model = "google";
                }
                else if (edition.Equals("Lite"))
                {
                    model = "lite";
                }
                else
                {
                    model = "full";
                }

                XmlNode androidPackages = xmlWriteDoc.CreateElement("androidPackages");
                dependencies.AppendChild(androidPackages);

                XmlNode repositories = xmlWriteDoc.CreateElement("repositories");
                androidPackages.AppendChild(repositories);

                XmlNode pangle = xmlWriteDoc.CreateElement("repository");
                pangle.InnerText = "https://artifact.bytedance.com/repository/pangle/";
                repositories.AppendChild(pangle);

                XmlNode ironsource = xmlWriteDoc.CreateElement("repository");
                ironsource.InnerText = "https://android-sdk.is.com/";
                repositories.AppendChild(ironsource);

                //XmlNode tapjoy = xmlWriteDoc.CreateElement("repository");
                //tapjoy.InnerText = "https://sdk.tapjoy.com/";
                //repositories.AppendChild(tapjoy);

                XmlNode mintegral = xmlWriteDoc.CreateElement("repository");
                mintegral.InnerText = "https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea";
                repositories.AppendChild(mintegral);

                //XmlNode aliDns = xmlWriteDoc.CreateElement("repository");
                //aliDns.InnerText = "http://maven.aliyun.com/nexus/content/repositories/releases/";
                //repositories.AppendChild(aliDns);

                if (!env.Equals("Release"))
                {
                    XmlNode maven = xmlWriteDoc.CreateElement("repository");
                    maven.InnerText = "https://oss.sonatype.org/content/repositories/snapshots/";
                    repositories.AppendChild(maven);
                }

                XmlNode androidPackage = xmlWriteDoc.CreateElement("androidPackage");
                androidPackages.AppendChild(androidPackage);
                XmlAttribute spec = xmlWriteDoc.CreateAttribute("spec");
                spec.Value = string.Format("com.yodo1.mas:{0}:{1}", model, version);
                androidPackage.Attributes.Append(spec);
            }
            else
            {
                XmlElement iosNode = (XmlElement)xnRead.SelectSingleNode("ios");
                string env = iosNode.GetAttribute("env").ToString();
                string version = iosNode.GetAttribute("version").ToString();
                string suffix = iosNode.GetAttribute("suffix").ToString();
                if (suffix != null && !suffix.Equals(""))
                {
                    version = version + "-" + suffix;
                }
                string model = string.Empty;
                if (edition.Equals("Lite"))
                {
                    model = "Yodo1MasLite";
                }
                else
                {
                    model = "Yodo1MasFull";
                }

                XmlNode iosPods = xmlWriteDoc.CreateElement("iosPods");
                dependencies.AppendChild(iosPods);

                XmlNode sources = xmlWriteDoc.CreateElement("sources");
                iosPods.AppendChild(sources);

                XmlNode masSource = xmlWriteDoc.CreateElement("source");
                if (env.Equals("Dev"))
                {
                    masSource.InnerText = "https://github.com/Yodo1Games/MAS-Spec-Dev.git";
                }
                else if (env.Equals("Pre"))
                {
                    masSource.InnerText = "https://github.com/Yodo1Games/MAS-Spec-Pre.git";
                }
                else
                {
                    masSource.InnerText = "https://github.com/Yodo1Games/MAS-Spec.git";
                }

                sources.AppendChild(masSource);

                XmlNode mas = xmlWriteDoc.CreateElement("iosPod");
                iosPods.AppendChild(mas);

                XmlAttribute masNameAttribute = xmlWriteDoc.CreateAttribute("name");
                masNameAttribute.Value = model;
                mas.Attributes.Append(masNameAttribute);

                XmlAttribute masVersionAttribute = xmlWriteDoc.CreateAttribute("version");
                masVersionAttribute.Value = version;
                mas.Attributes.Append(masVersionAttribute);

                XmlAttribute masMinTargetSdkAttribute = xmlWriteDoc.CreateAttribute("minTargetSdk");
                masMinTargetSdkAttribute.Value = "12.0";
                mas.Attributes.Append(masMinTargetSdkAttribute);
            }
            reader.Close();
            //附加根节点
            xmlWriteDoc.AppendChild(dependencies);
            xmlWriteDoc.InsertBefore(Declaration, xmlWriteDoc.DocumentElement);
            xmlWriteDoc.Save(destFile);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
