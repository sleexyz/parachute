import React from "react";
import { Frame } from "../../components/Frame";

export const FrameScreen = (): JSX.Element => {
  return (
    <div className="flex flex-col items-center justify-center relative overflow-x-hidden lg:overflow-x-auto">
      <div className="flex flex-col items-center gap-0 relative self-stretch w-full pb-48 lg:gap-[282px] lg:pt-[122px] lg:pb-[269px] lg:px-0 lg:relative lg:self-stretch lg:w-full lg:flex-[0_0_auto] [background:linear-gradient(180deg,_rgb(255,_255,_255)_0%,_rgb(255,_255,_255)_0.01%,_rgb(255,_222,_187)_100%)]">
        <div className="flex max-w-[1200px] px-4 lg:px-0 items-start justify-between relative w-full lg:flex-[0_0_auto]">
          <div className="flex h-[100vh] lg:h-[unset] flex-col justify-between items-start pt-12 lg:pt-0 px-0 relative self-stretch lg:flex-col lg:items-start lg:gap-[96px] lg:pb-[59px] lg:pt-0 lg:flex-[0_0_auto]"> <div className="relative w-[200px] h-[38px] lg:w-[445px] lg:h-[86px]">
            <div className="inline-flex items-center gap-4 lg:gap-8">
              <img className="w-[48px] h-[48px] lg:w-[76px] lg:h-[76px]" alt="Group" src="/img/group-221.png" />
              <div className="mb-2 [font-family:'SF_Pro_Rounded-Bold',_Helvetica] font-bold text-[#ff6f01] text-[42px] lg:text-[72px] tracking-[0] leading-[normal] whitespace-nowrap">
                parachute
              </div>
            </div>
          </div>
            <div className="relative w-fit [font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] text-[48px] lg:text-[48px] tracking-[0] leading-[normal]">
              Stop getting {" "} <span className="font-bold">sucked in.</span>
            </div>
            <p className="relative leading-normal w-[233px] h-[61px] [font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] text-[24px] lg:text-[36px] lg:w-[467px] lg:h-[122px] lg:text-[36px] lg:tracking-[0] lg:leading-[normal]">
              <span className="[font-family:'Space_Grotesk',_Helvetica] font-normal text-[#000000cc] lg:tracking-[0]">
                Delete the addictiveness, not your friends.
              </span>
            </p>
            <GetEarlyAccess className="mt-12 mb-36 lg:mt-0 lg:mb-0" />
          </div>
          <img
            className="hidden lg:block w-[278px] h-[386px] mt-[-24.00px] mb-[-24.00px] mr-[-24.00px] lg:relative lg:w-[556px] lg:h-[773px] lg:mt-[-48.00px] lg:mb-[-48.00px] lg:mr-[-48.00px]" alt="Iphone pro copy"
            src="/img/iphone-14-pro-copy-1-2560x1355-1-1.png"
          />
        </div>
        <div className="flex flex-col max-w-[1200px] items-start gap-20 relative w-full lg:flex-col lg:max-w-[1200px] lg:items-start lg:gap-[161px] lg:relative lg:w-full lg:rounded-[5px] lg:overflow-hidden">
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="default" />
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="variant-3" />
          <Frame className="!self-stretch !flex-[0_0_auto] !w-full" property1="variant-2" />
        </div>
      </div>
      <div className="flex flex-col h-[100vh] items-center justify-center gap-2 relative self-stretch w-full bg-black lg:h-[1024px]">
        <div className="flex px-4 flex-col max-w-[1200px] items-start justify-center gap-24 relative w-full lg:flex-col lg:max-w-[1200px] lg:items-start lg:justify-center lg:gap-[143px]">
          <img className="relative w-[89.63px] h-[89.62px] lg:w-[149.39px] lg:h-[149.35px]" alt="Group" src="/img/group-399.png" />
          <p className="relative w-[315px] [font-family:'Space_Grotesk',_Helvetica] font-normal text-white text-[24px] lg:text-[48px] lg:w-[630px] lg:text-[48px] lg:tracking-[0] lg:leading-[normal]">
            <span className="[font-family:'Space_Grotesk',_Helvetica] font-normal text-white lg:tracking-[0]">
              Social media, without the addiction.
            </span>
            {/* <span className="font-bold">now.</span> */}
          </p>
          <GetEarlyAccess color="white" />
        </div>
      </div>
    </div>
  );
};

export const GetEarlyAccess = (props: { className?: String, color?: String }): JSX.Element => {
  const { className = "" } = props;
  return (
    <a href="https://qp169voxkxx.typeform.com/to/LSkmOMsz" target="_blank" className={props.className}>
      <div className="flex w-[300px] items-start justify-around gap-4 px-[24px] py-[16px] relative flex-[0_0_auto] bg-[#d9d9d966] rounded-[10px] lg:w-[315px] lg:gap-[10px] lg:px-[46px] lg:py-[16px]">
        <div className="relative w-fit [font-family:'SF_Pro_Rounded-Regular',_Helvetica] font-normal text-[20px] lg:text-[24px] tracking-[0] leading-[normal]"
          style={{ color: props.color ?? "black" }}
        >
          Get early access (iOS)
        </div>
      </div>
    </a>
  )
}