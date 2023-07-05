using System.Collections;
using System.IO;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using Yodo1.MAS;

namespace Tests
{
    public class MASEditorTests
    {
        [Test]
        public void HasMASSDKImported()
        {
            Assert.IsTrue(Directory.Exists("Assets/Yodo1/MAS"));
        }
        [Test]
        public void HasSDKKeyEntered()
        {
            Yodo1AdSettings settings = Resources.Load("Yodo1/Yodo1AdSettings", typeof(Yodo1AdSettings)) as Yodo1AdSettings;
            Assert.IsNotNull(settings);
        }
        // A UnityTest behaves like a coroutine in Play Mode. In Edit Mode you can use
        // `yield return null;` to skip a frame.
        [UnityTest]
        public IEnumerator MASEditorTestsWithEnumeratorPasses()
        {
            // Use the Assert class to test conditions.
            // Use yield to skip a frame.
            yield return null;
        }
    }
}
