#pragma once

#include <cstdint>
#include "Flash.hpp"

namespace FPGA {

static constexpr uint16_t MaxPoints = 4501;

enum class Reg {
	InterruptMask = 0x00,
	SweepPoints = 0x01,
	SamplesPerPoint = 0x02,
	SystemControl = 0x03,
	SettlingTime = 0x04,
	MAX2871Def0LSB = 0x08,
	MAX2871Def0MSB = 0x09,
	MAX2871Def1LSB = 0x0A,
	MAX2871Def1MSB = 0x0B,
	MAX2871Def3LSB = 0x0C,
	MAX2871Def3MSB = 0x0D,
	MAX2871Def4LSB = 0x0E,
	MAX2871Def4MSB = 0x0F,
};

using SamplingResult = struct _samplingresult {
	int64_t P1I, P1Q;
	int64_t P2I, P2Q;
	int64_t RefI, RefQ;
};

using ADCLimits = struct _adclimits {
	int16_t P1min, P1max;
	int16_t P2min, P2max;
	int16_t Rmin, Rmax;
};

enum class Periphery {
	Port1Mixer = 0x8000,
	Port2Mixer = 0x4000,
	RefMixer = 0x2000,
	Amplifier = 0x1000,
	SourceRF = 0x0800,
	LO1RF = 0x0400,
	ExtRefLED = 0x0200,
	ReadyLED = 0x0100,
	DebugLED = 0x0080,
	SourceChip = 0x0010,
	LO1Chip = 0x0008,
	ExcitePort2 = 0x0004,
	ExcitePort1 = 0x0002,
};

enum class Interrupt {
	LO1Unlock = 0x0001,
	SourceUnlock = 0x0002,
	NewData = 0x0004,
	DataOverrun = 0x0008,
	SweepHalted = 0x0010,
};

enum class LowpassFilter {
	M947 = 0x00,
	M1880 = 0x01,
	M3500 = 0x02,
	None = 0x03,
	Auto = 0xFF,
};

enum class SettlingTime {
	us20 = 0x00,
	us60 = 0x01,
	us180 = 0x02,
	us540 = 0x03,
};

enum class Samples {
	SPPRegister = 0x00,
    S128 = 0x01,
	S384 = 0x02,
	S896 = 0x03,
	S3072 = 0x04,
	S9088 = 0x05,
	S30464 = 0x06,
	S91392 = 0x07,
};

enum class Window {
	None = 0x00,
	Kaiser = 0x01,
	Hann = 0x02,
	Flattop = 0x03,
};

bool Configure(Flash *f, uint32_t start_address, uint32_t bitstream_size);

using HaltedCallback = void(*)(void);
bool Init(HaltedCallback cb = nullptr);
void SetNumberOfPoints(uint16_t npoints);
void SetSamplesPerPoint(uint32_t nsamples);
void Enable(Periphery p, bool enable = true);
void Disable(Periphery p);
void SetWindow(Window w);
void EnableInterrupt(Interrupt i);
void DisableInterrupt(Interrupt i);
void WriteMAX2871Default(uint32_t *DefaultRegs);
void WriteSweepConfig(uint16_t pointnum, bool lowband, uint32_t *SourceRegs, uint32_t *LORegs,
		uint8_t attenuation, uint64_t frequency, SettlingTime settling, Samples samples, bool halt = false, LowpassFilter filter = LowpassFilter::Auto);
using ReadCallback = void(*)(SamplingResult result);
bool InitiateSampleRead(ReadCallback cb);
ADCLimits GetADCLimits();
void ResetADCLimits();
void ResumeHaltedSweep();
uint16_t GetStatus();

void StartSweep();
void AbortSweep();

enum class Mode {
	FPGA,
	SourcePLL,
	LOPLL,
};
void SetMode(Mode mode);


}