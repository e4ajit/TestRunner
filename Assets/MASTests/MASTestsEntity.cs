using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using Yodo1.MAS;
namespace Tests
{
    public class MASTestsEntity
    {
        GameObject objToSpawn;
        [SetUp]
        public void SetUp()
        {
            objToSpawn = new GameObject("AdManager");
            objToSpawn.AddComponent<Yodo1AdsTest>();
        }
        // A Test behaves as an ordinary method
        [Test]
        public void MASTestsEntitySimplePasses()
        {
            

            // Use the Assert class to test conditions
        }

        // A UnityTest behaves like a coroutine in Play Mode. In Edit Mode you can use
        // `yield return null;` to skip a frame.
        [UnityTest]
        public IEnumerator MASTestsEntityWithEnumeratorPasses()
        {
            // Use the Assert class to test conditions.
            // Use yield to skip a frame.
            yield return new WaitForSecondsRealtime(5.0f);
            Assert.AreEqual(objToSpawn.GetComponent<Yodo1AdsTest>().isSDKinitialized,true);
        }
    }
}
