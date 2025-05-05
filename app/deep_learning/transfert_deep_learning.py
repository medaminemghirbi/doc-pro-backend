from huggingface_hub import HfApi

api = HfApi()
api.upload_file(
    path_or_fileobj='app/deep_learning/adjusted_cnn.h5',
    path_in_repo='adjusted_cnn.h5',  # This is the file path inside the repo
    repo_id='mohamedaminemghirbi/PFE-Model',
    repo_type='model',
    token='REDACTED'
)
