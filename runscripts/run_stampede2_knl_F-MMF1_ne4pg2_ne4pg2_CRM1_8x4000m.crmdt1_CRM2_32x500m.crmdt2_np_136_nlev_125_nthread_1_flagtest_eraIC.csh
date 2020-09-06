#!/bin/bash
for COUNTER in 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018
do
sed -e "s/ERAYYY/${COUNTER}/g;" stampede2_knl_F-MMF1_ne4pg2_ne4pg2_CRM1_8x4000m.crmdt1_CRM2_32x500m.crmdt2_np_136_nlev_125_nthread_1_flagtest_eraIC.csh > stampede2_knl_F-MMF1_ne4pg2_ne4pg2_CRM1_8x4000m.crmdt1_CRM2_32x500m.crmdt2_np_136_nlev_125_nthread_1_flagtest_eraIC_${COUNTER}.csh

chmod 700 stampede2_knl_F-MMF1_ne4pg2_ne4pg2_CRM1_8x4000m.crmdt1_CRM2_32x500m.crmdt2_np_136_nlev_125_nthread_1_flagtest_eraIC_${COUNTER}.csh
./stampede2_knl_F-MMF1_ne4pg2_ne4pg2_CRM1_8x4000m.crmdt1_CRM2_32x500m.crmdt2_np_136_nlev_125_nthread_1_flagtest_eraIC_${COUNTER}.csh

done

#mv science_ne16_test_08102020_* /home1/07088/tg863871/temp/
