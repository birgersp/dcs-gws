function DCSUnit() {
    this.x = 0;
    this.z = 0;
    this.coalition = DCSUnit.coalition.RED;
    this.type = DCSUnit.types.TANK;
}

// TODO: Add unit types
DCSUnit.types = {
    TANK: "TANK",
    IFV: "IFV"
};

DCSUnit.coalition = {
    NEUTRAL: "NEUTRAL",
    RED: "RED",
    BLUE: "BLUE"
};