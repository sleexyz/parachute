/*
We're constantly improving the code you see. 
Please share your feedback here: https://form.asana.com/?k=uvp-HPgd3_hyoXRBw1IcNg&d=1152665201300829
*/

import PropTypes from "prop-types";
import React from "react";

interface Props {
  property1: "variant-2" | "variant-3" | "default";
  className: any;
}

export const Frame = ({ property1, className }: Props): JSX.Element => {
  return (
    <div
      className={`w-[1200px] flex items-start p-[60px] rounded-[60px] justify-between relative ${
        property1 === "variant-3" ? "bg-[#d9d9d966]" : property1 === "variant-2" ? "bg-[#73665e]" : "bg-[#ffdebb66]"
      } ${className}`}
    >
      <div className="flex self-stretch flex-col items-start grow flex-1 justify-between relative">
        <img
          className={`relative ${
            property1 === "variant-3" ? "w-[87.62px]" : property1 === "variant-2" ? "w-[104.77px]" : "w-[51.5px]"
          } ${property1 === "variant-3" ? "h-[104.68px]" : property1 === "variant-2" ? "h-[58.4px]" : "h-[80.82px]"}`}
          alt="Img"
          src={property1 === "variant-3" ? "/img/2.svg" : property1 === "variant-2" ? "/img/image.svg" : "/img/4.svg"}
        />
        <div
          className={`[font-family:'Space_Mono',_Helvetica] w-fit tracking-[0] text-[60px] relative font-normal leading-[normal] ${
            property1 === "variant-2" ? "text-white" : "text-black"
          }`}
        >
          {property1 === "default" && <>DELAY</>}

          {property1 === "variant-3" && <>DEPROGRAM</>}

          {property1 === "variant-2" && <>DETOX</>}
        </div>
      </div>
      <div className="[font-family:'Proxima_Soft-Regular',_Helvetica] mt-[-1.00px] tracking-[0] text-[32px] flex-1 text-transparent relative font-normal leading-[50px]">
        <span className={`${property1 === "variant-2" ? "text-[#ffffffcc]" : "text-[#00000099]"}`}>
          {property1 === "variant-2" && <>We live in a world with </>}

          {property1 === "default" && <>Parachute works by </>}

          {property1 === "variant-3" && <>By delaying reward, Parachute </>}
        </span>
        <span
          className={`[font-family:'Proxima_Soft-Bold',_Helvetica] font-bold ${
            property1 === "variant-2" ? "text-white" : "text-black"
          }`}
        >
          {property1 === "default" && <>delaying social media feeds</>}

          {property1 === "variant-3" && <>deprograms</>}

          {property1 === "variant-2" && <>infinite</>}
        </span>
        <span className={`${property1 === "variant-2" ? "text-[#ffffffcc]" : "text-[#00000099]"}`}>
          {property1 === "default" && (
            <>
              {" "}
              from loading, without removing the ability to message and post.
              <br />
              <br />
              <br />
              Stop getting{" "}
            </>
          )}

          {property1 === "variant-3" && (
            <>
              {" "}
              the circuits that keeps you checking your phone all the time.
              <br />
              <br />
              <br />
              Stop the{" "}
            </>
          )}

          {property1 === "variant-2" && <> scroll yet we have </>}
        </span>
        <span
          className={`[font-family:'Proxima_Soft-Bold',_Helvetica] font-bold ${
            property1 === "variant-2" ? "text-white" : "text-black"
          }`}
        >
          {property1 === "default" && <>sucked in </>}

          {property1 === "variant-3" && <>compulsive checking </>}

          {property1 === "variant-2" && <>finite</>}
        </span>
        <span className={`${property1 === "variant-2" ? "text-[#ffffffcc]" : "text-[#00000099]"}`}>
          {property1 === "default" && <>every time you check a message.</>}

          {property1 === "variant-3" && <>from breaking your flow.</>}

          {property1 === "variant-2" && (
            <>
              {" "}
              energy and attention.
              <br />
              <br />
              <br />
              Parachute makes social media consumption sustainable by default.
              <br />
            </>
          )}
        </span>
        {property1 === "variant-2" && (
          <p>
            <span className="[font-family:'Proxima_Soft-Bold',_Helvetica] font-bold text-white">
              No more binging and purging apps.
            </span>
          </p>
        )}
      </div>
    </div>
  );
};

Frame.propTypes = {
  property1: PropTypes.oneOf(["variant-2", "variant-3", "default"]),
};
