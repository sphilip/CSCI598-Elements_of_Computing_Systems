load Computer.hdl,
output-file computerJump.out,
compare-to computerJump.cmp,
output-list time%S1.4.1 ARegister[]%D1.7.1 DRegister[]%D1.7.1 PC[]%D0.4.0;

ROM32K load computerJump.hack;

repeat 55 {
    tick, tock, output;
}