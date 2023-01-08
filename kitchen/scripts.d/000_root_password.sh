echo "- Set password"
if [ -z "${ROOT_PASSWORD}" ]; then
  passwd -d root
else
  echo -e "${ROOT_PASSWORD}\n${ROOT_PASSWORD}" | passwd root
fi
