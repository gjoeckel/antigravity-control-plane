import litellm
from litellm.integrations.custom_logger import CustomLogger
import os
import json

class ACPCustomLogger(CustomLogger):
    """
    ACP Phase 3: PostgreSQL Telemetry Handler
    Intercepts X-AND-TRACE and X-AND-SESSION headers for sovereign logging.
    """
    def log_pre_api_call(self, model, messages, kwargs, print_verbose):
        pass

    def log_post_api_call(self, kwargs, response_obj, start_time, end_time):
        pass

    def log_success_event(self, kwargs, response_obj, start_time, end_time):
        """
        Triggered on successful LLM responses.
        Captures metadata and traces to the existing LiteLLM Postgres table.
        """
        try:
            # Extract custom headers from the original request
            # LiteLLM stores the proxy headers in 'proxy_server_request'
            proxy_req = kwargs.get("call_kwargs", {})
            headers = proxy_req.get("headers", {})
            
            trace_id = headers.get("X-AND-TRACE", headers.get("x-and-trace", "unknown-trace"))
            session_id = headers.get("X-AND-SESSION", headers.get("x-and-session", "unknown-session"))
            
            # Metadata for internal debugging
            metadata = kwargs.get("litellm_params", {}).get("metadata", {})
            metadata["acp_trace_id"] = trace_id
            metadata["acp_session_id"] = session_id

            # Capture Tool Usage Telemetry
            if hasattr(response_obj, 'choices') and len(response_obj.choices) > 0:
                message = response_obj.choices[0].message
                if hasattr(message, 'tool_calls') and message.tool_calls:
                    tool_name = message.tool_calls[0].function.name
                    metadata["tool_used"] = tool_name
                    print(f"ACP-TOOL: {tool_name} triggered for Session {session_id}")
            
            print(f"ACP Telemetry: Logged Trace {trace_id} for Session {session_id}")
            
        except Exception as e:
            print(f"ACP Telemetry Error: {str(e)}")

    def log_failure_event(self, kwargs, response_obj, start_time, end_time):
        pass

    def async_log_success_event(self, kwargs, response_obj, start_time, end_time):
        try:
            # Extract custom headers from the original request
            # LiteLLM stores the proxy headers in 'proxy_server_request'
            proxy_req = kwargs.get("call_kwargs", {})
            headers = proxy_req.get("headers", {})
            
            trace_id = headers.get("X-AND-TRACE", headers.get("x-and-trace", "unknown-trace"))
            session_id = headers.get("X-AND-SESSION", headers.get("x-and-session", "unknown-session"))
            
            # Metadata for internal debugging
            metadata = kwargs.get("litellm_params", {}).get("metadata", {})
            metadata["acp_trace_id"] = trace_id
            metadata["acp_session_id"] = session_id

            # Capture Tool Usage Telemetry (Async)
            if hasattr(response_obj, 'choices') and len(response_obj.choices) > 0:
                message = response_obj.choices[0].message
                if hasattr(message, 'tool_calls') and message.tool_calls:
                    tool_name = message.tool_calls[0].function.name
                    metadata["tool_used"] = tool_name
                    print(f"ACP-TOOL (Async): {tool_name} triggered for Session {session_id}")
            
            print(f"ACP Telemetry (Async): Logged Trace {trace_id} for Session {session_id}")
            
        except Exception as e:
            print(f"ACP Telemetry Error (Async): {str(e)}")


# Register the callback globally for LiteLLM
proxy_custom_logger = ACPCustomLogger()
