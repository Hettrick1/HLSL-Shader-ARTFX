using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tide : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        transform.position += new Vector3(0, (float)(Math.Sin(Time.fixedTime) * 0.005), 0);
    }
}
