using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class ProceduralCube : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        MakeCube();
    }

    void MakeCube() {
        Vector3[] vertices = {
            new Vector3(0, 0, 0),
            new Vector3(1, 0, 0),
            new Vector3(1, 1, 0),
            new Vector3(0, 1, 0),
            new Vector3(0, 1, 1),
            new Vector3(1, 1, 1),
            new Vector3(1, 0, 1),
            new Vector3(0, 0, 1)
        };

        int[] triangles = {
            0, 2, 1, // south face
            0, 3, 2,
            3, 4, 5, // top face
            3, 5, 2,
            1, 5, 6, // east face
            1, 2, 5,
            0, 7, 4, // west face
            0, 4, 3,
            7, 5, 4, // north face
            7, 6, 5,
            0, 6, 7, // down face
            0, 1, 6
        };

        mesh = GetComponent<MeshFilter>().mesh;
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
    }


    void OnDestroy() {
        Destroy(mesh);
    }
}
