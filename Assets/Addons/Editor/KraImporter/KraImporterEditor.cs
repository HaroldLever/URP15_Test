using UnityEngine;
using UnityEditor;
using UnityEngine.UIElements;
using UnityEditor.UIElements;
using UnityEditor.AssetImporters;

[CustomEditor(typeof(KraImporter))]
[CanEditMultipleObjects]
public class KraImporterEditor : ScriptedImporterEditor
{
    private SerializedProperty m_WrapMode;
    private SerializedProperty m_FilterMode;
    private SerializedProperty m_AnisoLevel;

    // public override void OnEnable()
    // {
    //     m_WrapMode = serializedObject.FindProperty("wrapMode");
    //     m_FilterMode = serializedObject.FindProperty("filterMode");
    //     m_AnisoLevel = serializedObject.FindProperty("anisoLever");

    // }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        m_WrapMode = serializedObject.FindProperty("wrapMode");
        m_FilterMode = serializedObject.FindProperty("filterMode");
        m_AnisoLevel = serializedObject.FindProperty("anisoLevel");

        EditorGUILayout.PropertyField(m_WrapMode);
        EditorGUILayout.PropertyField(m_FilterMode);
        m_AnisoLevel.intValue = EditorGUILayout.IntSlider("Aniso Level", m_AnisoLevel.intValue, 0, 16);
        
        serializedObject.ApplyModifiedProperties();
        ApplyRevertGUI();
    }
}