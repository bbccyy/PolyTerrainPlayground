using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(BTSkyCore))]
public class BTSkyEditor : Editor
{
    #region BTSkyObj
    SerializedProperty mainLight;
    SerializedProperty mainCamera;

    SerializedProperty atmoSphere;
    SerializedProperty sun;
    SerializedProperty moon;
    SerializedProperty cloud_1;
    SerializedProperty cloud_2;
    SerializedProperty cloud_3;
    #endregion

    #region Time
    SerializedProperty seconds;
    SerializedProperty minutes;
    SerializedProperty hours;
    //SerializedProperty reverseTime;
    SerializedProperty cycleLengthInMinutes;
    SerializedProperty dayLengthRate;
    #endregion

    #region fog
    SerializedProperty fog;
    SerializedProperty fogMode;
    SerializedProperty fogColor;
    SerializedProperty fogDensity;
    SerializedProperty fogStartDistance;
    SerializedProperty fogEndDistance;
    #endregion

    #region Light
    SerializedProperty mainLightColor;
    SerializedProperty mainLightIntensity;
    SerializedProperty shadowAngleBias;
    #endregion

    //Profile Properties
    #region AtmoSphere
    SerializedProperty skyWorldUpDir;
    SerializedProperty topFrontColor;
    SerializedProperty topBackColor;
    SerializedProperty bottomFrontColor;
    SerializedProperty bottomBackColor;
    SerializedProperty skyFrontAndBackBlendFactor;
    //SerializedProperty skyGradientBlendFactor;
    SerializedProperty bottomColorHeight;
    SerializedProperty horizonHaloColor;
    SerializedProperty horizonHaloIntensity;
    SerializedProperty horizonHaloHeight;
    //#endregion

    //#region Stars
    SerializedProperty starsScintillation;
    SerializedProperty starBrightness;
    SerializedProperty starsDensity;
    #endregion


    #region Sun
    SerializedProperty sunSizeScale;
    SerializedProperty sunColor;
    SerializedProperty sunBrightness;
    SerializedProperty sunRimLightRadius;
    SerializedProperty sunHaloSize;
    SerializedProperty sunHaloColor;
    SerializedProperty sunHaloInstensity;
    SerializedProperty sunSharpness;
    #endregion

    #region Moon
    //SerializedProperty moonDirection;
    SerializedProperty moonSizeScale;
    SerializedProperty moonGlowSize;
    SerializedProperty moonColor;
    SerializedProperty moonBrightness;
    SerializedProperty moonGlowIntensity;
    SerializedProperty moonLunarPhase;
    #endregion

    #region Cloud
    SerializedProperty atlasTiles;
    SerializedProperty cloudElapsedTime;
    SerializedProperty rotationSpeed;
    SerializedProperty cloudLightFrontColor;
    SerializedProperty cloudLightBackColor;
    SerializedProperty cloudDarkFrontColor;
    SerializedProperty cloudDarkBackColor;
    SerializedProperty cloudFrontAndBackBlendFactor;
    SerializedProperty cloudCoverage;
    SerializedProperty cloudAgePercent;
    SerializedProperty cloudSunBrightenIntensity;


    SerializedProperty cloudDirection;
    SerializedProperty cloudHeight;
    SerializedProperty cloudTiling;
    SerializedProperty cloudOpacity;
    SerializedProperty cloudSmoothness;
    SerializedProperty cloudWispsElapsedTime;
    SerializedProperty cloudWispsCoverage;
    SerializedProperty cloudWispsOpacity;
    #endregion

    private void SerializeESObj()
    {
        mainLight = serializedObject.FindProperty("mainLight");
        mainCamera = serializedObject.FindProperty("mainCamera");
        atmoSphere = serializedObject.FindProperty("atmoSphere");
        sun = serializedObject.FindProperty("sun");
        moon = serializedObject.FindProperty("moon");
        cloud_1 = serializedObject.FindProperty("cloud_1");
        cloud_2 = serializedObject.FindProperty("cloud_2");
        cloud_3 = serializedObject.FindProperty("cloud_3");
    }

    private void SerializeTime()
    {
        seconds = serializedObject.FindProperty("seconds");
        minutes = serializedObject.FindProperty("minutes");
        hours = serializedObject.FindProperty("hours");
        //reverseTime = serializedObject.FindProperty("reverseTime");
        cycleLengthInMinutes = serializedObject.FindProperty("cycleLengthInMinutes");
        dayLengthRate = serializedObject.FindProperty("dayLengthRate");
    }

    private void SerializeFog()
    {
        fog = serializedObject.FindProperty("fog");
        fogMode = serializedObject.FindProperty("fogMode");
        fogColor = serializedObject.FindProperty("fogColor");
        fogDensity = serializedObject.FindProperty("fogDensity");
        fogStartDistance = serializedObject.FindProperty("fogStartDistance");
        fogEndDistance = serializedObject.FindProperty("fogEndDistance");
    }

    private void SerializeLight()
    {
        mainLightColor = serializedObject.FindProperty("mainLightColor");
        mainLightIntensity = serializedObject.FindProperty("mainLightIntensity");
        shadowAngleBias = serializedObject.FindProperty("shadowAngleBias");
    }

    private void SerializeAtmoSphere()
    {
        skyWorldUpDir = serializedObject.FindProperty("skyWorldUpDir");

        topFrontColor = serializedObject.FindProperty("topFrontColor");
        topBackColor = serializedObject.FindProperty("topBackColor");
        bottomFrontColor = serializedObject.FindProperty("bottomFrontColor");
        bottomBackColor = serializedObject.FindProperty("bottomBackColor");
        skyFrontAndBackBlendFactor = serializedObject.FindProperty("skyFrontAndBackBlendFactor");
        bottomColorHeight = serializedObject.FindProperty("bottomColorHeight");
        horizonHaloColor = serializedObject.FindProperty("horizonHaloColor");
        horizonHaloIntensity = serializedObject.FindProperty("horizonHaloIntensity");
        horizonHaloHeight = serializedObject.FindProperty("horizonHaloHeight");

        starsScintillation = serializedObject.FindProperty("starsScintillation");
        starBrightness = serializedObject.FindProperty("starBrightness");
        starsDensity = serializedObject.FindProperty("starsDensity");
    }

    private void SerializeSun()
    {
        sunSizeScale = serializedObject.FindProperty("sunSizeScale");
        sunColor = serializedObject.FindProperty("sunColor");
        sunBrightness = serializedObject.FindProperty("sunBrightness");
        sunRimLightRadius = serializedObject.FindProperty("sunRimLightRadius");
        sunHaloSize = serializedObject.FindProperty("sunHaloSize");
        sunHaloColor = serializedObject.FindProperty("sunHaloColor");
        sunHaloInstensity = serializedObject.FindProperty("sunHaloInstensity");
        sunSharpness = serializedObject.FindProperty("sunSharpness");
    }

    private void SerializeMoon()
    {
        moonSizeScale = serializedObject.FindProperty("moonSizeScale");
        moonGlowSize = serializedObject.FindProperty("moonGlowSize");
        moonColor = serializedObject.FindProperty("moonColor");
        moonBrightness = serializedObject.FindProperty("moonBrightness");
        moonGlowIntensity = serializedObject.FindProperty("moonGlowIntensity");
        moonLunarPhase = serializedObject.FindProperty("moonLunarPhase");
    }

    private void SerializeClouds()
    {
        atlasTiles = serializedObject.FindProperty("atlasTiles");
        cloudElapsedTime = serializedObject.FindProperty("cloudElapsedTime");
        //cloudDirection = serializedObject.FindProperty("cloudDirection");
        rotationSpeed = serializedObject.FindProperty("rotationSpeed");
        cloudLightFrontColor = serializedObject.FindProperty("cloudLightFrontColor");
        cloudLightBackColor = serializedObject.FindProperty("cloudLightBackColor");
        cloudDarkFrontColor = serializedObject.FindProperty("cloudDarkFrontColor");
        cloudDarkBackColor = serializedObject.FindProperty("cloudDarkBackColor");
        cloudFrontAndBackBlendFactor = serializedObject.FindProperty("cloudFrontAndBackBlendFactor");

        //cloudHeight = serializedObject.FindProperty("cloudHeight");
        //cloudTiling = serializedObject.FindProperty("cloudTiling");

        cloudCoverage = serializedObject.FindProperty("cloudCoverage");
        cloudAgePercent = serializedObject.FindProperty("cloudAgePercent");

        //cloudOpacity = serializedObject.FindProperty("cloudOpacity");
        //cloudSmoothness = serializedObject.FindProperty("cloudSmoothness");

        cloudSunBrightenIntensity = serializedObject.FindProperty("cloudSunBrightenIntensity");

        //cloudWispsElapsedTime = serializedObject.FindProperty("cloudWispsElapsedTime");
        //cloudWispsCoverage = serializedObject.FindProperty("cloudWispsCoverage");
        //cloudWispsOpacity = serializedObject.FindProperty("cloudWispsOpacity");
    }

    private void OnEnable()
    {
        //SerializeSky();
        SerializeESObj();
        SerializeTime();
        SerializeFog();
        SerializeLight();
        SerializeAtmoSphere();
        SerializeSun();
        SerializeMoon();
        SerializeClouds();
    }

    private void InspectorESObjGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(mainLight, new GUIContent("Main Light"));
        EditorGUILayout.PropertyField(mainCamera, new GUIContent("Main Camera"));
        EditorGUILayout.PropertyField(atmoSphere, new GUIContent("AtmoSphere"));
        EditorGUILayout.PropertyField(sun, new GUIContent("SunObj"));
        EditorGUILayout.PropertyField(moon, new GUIContent("MoonObj"));
        EditorGUILayout.PropertyField(cloud_1, new GUIContent("Cloud_1"));
        EditorGUILayout.PropertyField(cloud_2, new GUIContent("Cloud_2"));
        EditorGUILayout.PropertyField(cloud_3, new GUIContent("Cloud_3"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorTimeGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(seconds, new GUIContent("Seconds"));
        EditorGUILayout.PropertyField(minutes, new GUIContent("Minutes"));
        EditorGUILayout.PropertyField(hours, new GUIContent("Hours"));
        //EditorGUILayout.PropertyField(reverseTime, new GUIContent("ReverseTime"));
        EditorGUILayout.PropertyField(cycleLengthInMinutes, new GUIContent("CycleLengthInMinutes"));
        EditorGUILayout.PropertyField(dayLengthRate, new GUIContent("DayLengthRate"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorFogGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(fog, new GUIContent("Fog"));
        EditorGUILayout.PropertyField(fogMode, new GUIContent("FogMode"));
        EditorGUILayout.PropertyField(fogColor, new GUIContent("FogColor"));
        EditorGUILayout.PropertyField(fogDensity, new GUIContent("FogDensity"));
        EditorGUILayout.PropertyField(fogStartDistance, new GUIContent("FogStartDistance"));
        EditorGUILayout.PropertyField(fogEndDistance, new GUIContent("FogEndDistance"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorLightGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(mainLightColor, new GUIContent("MainLightColor"));
        EditorGUILayout.PropertyField(mainLightIntensity, new GUIContent("MainLightIntensity"));
        EditorGUILayout.PropertyField(shadowAngleBias, new GUIContent("ShadowAngleBias"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorAtmoSphereGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(skyWorldUpDir, new GUIContent("SkyWorldSpaceUpDir"));
        EditorGUILayout.PropertyField(topFrontColor, new GUIContent("TopFrontColor"));
        EditorGUILayout.PropertyField(topBackColor, new GUIContent("TopBackColor"));
        EditorGUILayout.PropertyField(bottomFrontColor, new GUIContent("BottomFrontColor"));
        EditorGUILayout.PropertyField(bottomBackColor, new GUIContent("bottomBackColor"));
        EditorGUILayout.PropertyField(skyFrontAndBackBlendFactor, new GUIContent("SkyFrontAndBackBlendFactor"));
        EditorGUILayout.PropertyField(bottomColorHeight, new GUIContent("BottomColorHeight"));
        EditorGUILayout.PropertyField(horizonHaloColor, new GUIContent("HorizonHaloColor"));
        EditorGUILayout.PropertyField(horizonHaloIntensity, new GUIContent("HorizonHaloIntensity"));
        EditorGUILayout.PropertyField(horizonHaloHeight, new GUIContent("HorizonHaloHeight"));

        EditorGUILayout.PropertyField(starsScintillation, new GUIContent("StarScintillation"));
        EditorGUILayout.PropertyField(starBrightness, new GUIContent("StarBrightness"));
        EditorGUILayout.PropertyField(starsDensity, new GUIContent("StarDensity"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorSunGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(sunSizeScale, new GUIContent("SunSizeScale"));
        EditorGUILayout.PropertyField(sunColor, new GUIContent("SunColor"));
        EditorGUILayout.PropertyField(sunBrightness, new GUIContent("SunBrightness"));
        EditorGUILayout.PropertyField(sunRimLightRadius, new GUIContent("SunRimLightRadius"));
        EditorGUILayout.PropertyField(sunHaloSize, new GUIContent("SunHaloSize"));
        EditorGUILayout.PropertyField(sunHaloColor, new GUIContent("SunHaloColor"));
        EditorGUILayout.PropertyField(sunHaloInstensity, new GUIContent("SunHaloInstensity"));
        EditorGUILayout.PropertyField(sunSharpness, new GUIContent("SunSharpness"));
        
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorMoonGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);

        EditorGUILayout.PropertyField(moonSizeScale, new GUIContent("MoonSizeScale"));
        EditorGUILayout.PropertyField(moonGlowSize, new GUIContent("MoonGlowSize"));
        EditorGUILayout.PropertyField(moonColor, new GUIContent("MoonColor"));
        EditorGUILayout.PropertyField(moonBrightness, new GUIContent("MoonBrightness"));
        EditorGUILayout.PropertyField(moonGlowIntensity, new GUIContent("MoonGlowIntensity"));
        EditorGUILayout.PropertyField(moonLunarPhase, new GUIContent("MoonLunarPhase"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    private void InspectorCloudsGUI()
    {
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical(EditorStyles.objectFieldThumb);
        
        EditorGUILayout.PropertyField(rotationSpeed, new GUIContent("RotationSpeed"));
        EditorGUILayout.PropertyField(cloudLightFrontColor, new GUIContent("CloudLightFrontColor"));
        EditorGUILayout.PropertyField(cloudLightBackColor, new GUIContent("CloudLightBackColor"));
        EditorGUILayout.PropertyField(cloudDarkFrontColor, new GUIContent("CloudDarkFrontColor"));
        EditorGUILayout.PropertyField(cloudDarkBackColor, new GUIContent("CloudDarkBackColor"));
        EditorGUILayout.PropertyField(cloudFrontAndBackBlendFactor, new GUIContent("CloudFrontAndBackBlendFactor"));
        EditorGUILayout.PropertyField(cloudCoverage, new GUIContent("CloudCoverage"));
        EditorGUILayout.PropertyField(cloudSunBrightenIntensity, new GUIContent("CloudSunBrightenIntensity"));
        EditorGUILayout.PropertyField(cloudElapsedTime, new GUIContent("CloudElapsedTime"));
        EditorGUILayout.PropertyField(cloudAgePercent, new GUIContent("CloudAgePercent"));

        EditorGUILayout.PropertyField(atlasTiles, new GUIContent("AtlasTiles"));
        
        //EditorGUILayout.PropertyField(cloudDirection, new GUIContent("CloudDirection"));
        //EditorGUILayout.PropertyField(cloudHeight, new GUIContent("CloudHeight"));
        //EditorGUILayout.PropertyField(cloudTiling, new GUIContent("CloudTiling"));  
        //EditorGUILayout.PropertyField(cloudOpacity, new GUIContent("CloudOpacity"));
        //EditorGUILayout.PropertyField(cloudSmoothness, new GUIContent("CloudSmoothness"));
        //EditorGUILayout.PropertyField(cloudWispsElapsedTime, new GUIContent("CloudWispsElapsedTime"));
        //EditorGUILayout.PropertyField(cloudWispsCoverage, new GUIContent("CloudWispsCoverage"));
        //EditorGUILayout.PropertyField(cloudWispsOpacity, new GUIContent("CloudWispsOpacity"));

        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
    }

    public override void OnInspectorGUI()
    {
        //InspectorSkyGUI();
        InspectorESObjGUI();
        InspectorTimeGUI();
        InspectorFogGUI();
        InspectorLightGUI();
        InspectorAtmoSphereGUI();
        InspectorSunGUI();
        InspectorMoonGUI();
        InspectorCloudsGUI();
        serializedObject.ApplyModifiedProperties();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
