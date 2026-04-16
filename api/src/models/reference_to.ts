import { Type } from "./enum";
export default class ReferenceTo {
    public type?: Type;
    public table?: string;
    public column?: string;
}