import React from "react";
import { Frame } from "../../components/Frame";

export const FrameScreen = (): JSX.Element => {
  return (
    <div className="flex flex-col items-center justify-center relative">
      <div className="flex flex-col items-center gap-[282px] pt-[122px] pb-[269px] px-[120px] relative self-stretch w-full flex-[0_0_auto] [background:linear-gradient(180deg,_rgb(255,_255,_255)_0%,_rgb(255,_255,_255)_0.01%,_rgb(255,_222,_187)_100%)]">
        <div className="flex max-w-[1440px] items-start justify-between relative self-stretch w-full flex-[0_0_auto]">
          <div className="inline-flex flex-col items-start gap-[96px] pt-0 pb-[59px] px-0 relative self-stretch flex-[0_0_auto]">
            <div className="relative w-[445px] h-[86px]">
              <div className="absolute w-[337px] h-[86px] top-0 left-[110px]">
                <div className="absolute top-0 left-0 [font-family:'SF_Pro_Rounded-Bold',_Helvetica] font-bold text-[#ff6f01] text-[72px] tracking-[0] leading-[normal] whitespace-nowrap">
                  parachute
                </div>
              </div>
              <img className="absolute w-[76px] h-[76px] top-[10px] left-0" alt="Group" src="/img/group-221.png" />
            </div>
            <div className="relative w-fit [font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] text-[48px] tracking-[0] leading-[normal]">
              Deprogram your mind.
            </div>
            <p className="relative w-[467px] h-[122px] [font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] text-[36px] tracking-[0] leading-[normal]">
              <span className="[font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] text-[36px] tracking-[0]">
                Start your 1-week dopamine detox{" "}
              </span>
              <span className="font-bold">now.</span>
            </p>
            <div className="flex w-[315px] items-start justify-around gap-[10px] px-[46px] py-[16px] relative flex-[0_0_auto] bg-[#d9d9d966] rounded-[20px]">
              <div className="relative w-fit [font-family:'SF_Pro_Rounded-Regular',_Helvetica] font-normal text-black text-[24px] tracking-[0] leading-[normal]">
                Get early access (iOS)
              </div>
            </div>
          </div>
          <img
            className="relative w-[556px] h-[773px] mt-[-48.00px] mb-[-48.00px] mr-[-48.00px]"
            alt="Iphone pro copy"
            src="/img/iphone-14-pro-copy-1-2560x1355-1-1.png"
          />
        </div>
        <div className="flex flex-col items-start gap-[200px] relative self-stretch w-full flex-[0_0_auto] rounded-[5px] overflow-hidden">
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="default" />
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="variant-3" />
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="variant-2" />
        </div>
      </div>
      <div className="flex flex-col h-[1024px] items-center justify-center gap-[10px] relative self-stretch w-full bg-black">
        <div className="flex flex-col max-w-[1440px] items-start justify-center gap-[103px] px-[120px] py-0 relative self-stretch w-full flex-[0_0_auto]">
          <img className="relative w-[149.39px] h-[149.35px]" alt="Group" src="/img/group-399.png" />
          <p className="relative w-[630px] h-[284px] [font-family:'Space_Grotesk',_Helvetica] font-normal text-white text-[48px] tracking-[0] leading-[normal]">
            <span className="[font-family:'Space_Grotesk',_Helvetica] font-normal text-white text-[48px] tracking-[0]">
              Start your 1-week dopamine detox{" "}
            </span>
            <span className="font-bold">now.</span>
          </p>
          <div className="relative w-[317px] h-[61px]">
            <div className="relative w-[315px] h-[61px] bg-[#d9d9d966] rounded-[20px]">
              <div className="absolute top-[16px] left-[46px] [font-family:'SF_Pro_Rounded-Regular',_Helvetica] font-normal text-white text-[24px] tracking-[0] leading-[normal]">
                Get early access (iOS)
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
