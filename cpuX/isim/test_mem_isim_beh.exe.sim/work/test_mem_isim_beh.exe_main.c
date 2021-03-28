/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    xilinxcorelib_ver_m_00000000001358910285_2343122980_init();
    xilinxcorelib_ver_m_00000000001687936702_2843080771_init();
    xilinxcorelib_ver_m_00000000000277421008_3555355990_init();
    xilinxcorelib_ver_m_00000000001603977570_2117014577_init();
    work_m_00000000000403262735_2461264495_init();
    work_m_00000000002795924366_2381739659_init();
    work_m_00000000003379062936_1334121354_init();
    work_m_00000000002111511189_3372677183_init();
    work_m_00000000001683390505_1534925693_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000001683390505_1534925693");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
