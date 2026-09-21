// Let named-field backend tests exercise either bootstrap or self-emitted APIs.
// Select the actual compiler with BEND_TYPED_API; no compilation happens here.
import {loadApi} from './typed-driver.mjs';
export default await loadApi();
