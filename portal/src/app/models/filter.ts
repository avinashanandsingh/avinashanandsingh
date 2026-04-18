import Criteria from "./criteria";

export default class Filter {
  public criteria?: Criteria[];
  public orderBy?: { column: string; asc: boolean }[];
  public offset?: number;
  public limit?: number;
}
