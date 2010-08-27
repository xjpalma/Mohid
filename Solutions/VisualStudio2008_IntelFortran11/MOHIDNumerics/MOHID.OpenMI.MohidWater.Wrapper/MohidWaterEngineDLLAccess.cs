﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace MOHID.OpenMI.MohidWater.Wrapper
{
    public class MohidWaterEngineDLLAccess
    {
        //TODO: Check how to set this path during runtime ou by compiler reference...
        private const string dllPath = @"D:\Software\Mohid\MOHID.Numerics\Solutions\VisualStudio2008_IntelFortran11\MOHIDNumerics\MohidWaterEngine\Debug OpenMI\MohidWaterEngine.dll";

        [DllImport(dllPath, EntryPoint = "INITIALIZE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool Initialize(string filePath, uint length);

        [DllImport(dllPath, EntryPoint = "PERFORMTIMESTEP", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool PerformTimeStep();

        [DllImport(dllPath, EntryPoint = "GETSTARTINSTANT", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GetStartInstant([MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        [DllImport(dllPath, EntryPoint = "GETSTOPINSTANT", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GetStopInstant([MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        [DllImport(dllPath, EntryPoint = "GETCURRENTINSTANT", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GetCurrentInstant([MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        [DllImport(dllPath, EntryPoint = "GETCURRENTTIMESTEP", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetCurrentTimeStep();

        [DllImport(dllPath, EntryPoint = "GETMODELID", SetLastError = true, ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GetModelID([MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        [DllImport(dllPath, EntryPoint = "GETNUMBEROFMESSAGES",SetLastError = true,ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetNumberOfMessages();

        [DllImport(dllPath,EntryPoint = "GETMESSAGE",SetLastError = true,ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetMessage(ref int messageID, [MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        #region Module Discharges

        [DllImport(dllPath, EntryPoint = "GETNUMBEROFDISCHARGES", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetNumberOfDischarges(ref int instanceID);

        [DllImport(dllPath, EntryPoint = "GETDISCHARGETYPE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetDischargeType(ref int instanceID, ref int dischargeID);

        [DllImport(dllPath, EntryPoint = "GETDISCHARGEXCOORDINATE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetDischargeXCoordinate(ref int instanceID, ref int dischargeID);

        [DllImport(dllPath, EntryPoint = "GETDISCHARGEYCOORDINATE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetDischargeYCoordinate(ref int instanceID, ref int dischargeID);

        [DllImport(dllPath, EntryPoint = "GETDISCHARGENAME", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool GetDischargeName(ref int instanceID, ref int dischargeID, [MarshalAs(UnmanagedType.LPStr)] StringBuilder id, uint length);

        [DllImport(dllPath, EntryPoint = "SETDISCHARGEFLOW", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool SetDischargeFlow(ref int instanceID, ref int dischargeID, ref double flow);

        #endregion

        #region Module HorizontalGrid / Map

        [DllImport(dllPath, EntryPoint = "GETIUB", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetIUB(ref int horizontalGridInstanceID);

        [DllImport(dllPath, EntryPoint = "GETJUB", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern int GetJUB(ref int horizontalGridInstanceID);

        [DllImport(dllPath, EntryPoint = "ISWATERPOINT", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern bool IsWaterPoint(ref int horizontalGridInstanceID, ref int i, ref int j);

        [DllImport(dllPath, EntryPoint = "GETCENTERXCOORDINATE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetCenterXCoordinate(ref int horizontalGridInstanceID, ref int i, ref int j);

        [DllImport(dllPath, EntryPoint = "GETCENTERYCOORDINATE", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetCenterYCoordinate(ref int horizontalGridInstanceID, ref int i, ref int j);
        
        #endregion

        #region

        [DllImport(dllPath, EntryPoint = "GETWATERLEVELATPOINT", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetWaterLevelAtPoint(ref int hydrodynamicInstanceID, ref int i, ref int j);

        #endregion

        [DllImport(dllPath,EntryPoint = "RUNSIMULATION",SetLastError = true,ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern bool RunSimulation();

        #region Destructor

        [DllImport(dllPath,EntryPoint = "FINISH",SetLastError = true,ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern bool Finish();

        [DllImport(dllPath,EntryPoint = "DISPOSE",SetLastError = true,ExactSpelling = true,CallingConvention = CallingConvention.Cdecl)]
        public static extern bool Dispose();

        
        #endregion




    }
}

